#!/bin/bash

# ----------------------------------------------------------------------
# NGINX certificate update script.
# Last updated: 18.06.2022
# ----------------------------------------------------------------------
#
# Copyright 2021-2022 HCL America, Inc.
# Copyright 2021-2022 Nash!Com, Daniel Nashed
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------
#
#
# Deploys and updates certificates from remote server via SNI request querying certificates.
# The current certificate file is compared with the remote certificate.
# In case the certificate is matching they key and is updated  the certificate is updated and NGINX is reloaded.
#
# Also supports import of keys and certificates from a local mount
#
# ----------------------------


# Hostname key and cerficate file
HOST_NAME=certmgr.acme.com
SERVER_KEY=server.key
SERVER_CERT=server.pem


# CertMgr host to download certificates form via SNI request
CERTMGR_HOST=www.acme.com


# Import file and import password (automatically created)
IMPORT_PEM_FILE=import.pem
IMPORT_PASSWORD_FILE=import.pwd


# Temp file used for all operations
TMP_UPD_PEM_FILE=/tmp/cert_update.pem


# Adopt this function for your environment

notifiy_applications()
{
  # Add all application commands needed to make application aware of new certificate

  log_space "Reloading NGINX configuration due to certificate update"

  if [ "$EUID" = "0" ]; then
    nginx -s reload
  else
    sudo nginx -s reload
  fi

  return 0
}

# Helper functions

log_space()
{
  echo
  echo "$@"
  echo
}

log_error()
{
  echo
  echo "ERROR - $@"
  echo
}

log_debug()
{
  if [ -z "$DEBUG" ]; then
    return 0
  fi

  echo "DEBUG - $@"
}

remove_file()
{
  if [ -z "$1" ]; then
    return 1
  fi

  if [ ! -e "$1" ]; then
    return 2
  fi

  ERR_TXT=$(rm -f "$1" >/dev/null 2>/dev/null)

  if [ -e "$1" ]; then
    echo "Info: File not deleted [$1]"
  fi

  return 0
}

nsh_cmp()
{
  if [ -z "$1" ]; then
    return 1
  fi

  if [ -z "$2" ]; then
    return 1
  fi

  if [ ! -e "$1" ]; then
    return 1
  fi

  if [ ! -e "$2" ]; then
    return 1
  fi

  if [ -x /usr/bin/cmp ]; then
    cmp -s "$1" "$2"
    return $?
  fi

  HASH1=$(sha256sum "$1" | cut -d" " -f1)
  HASH2=$(sha256sum "$2" | cut -d" " -f1)

  if [ "$HASH1" = "$HASH2" ]; then
    return 0
  fi

  return 1
}

show_cert()
{
  if [ -z "$1" ]; then
    return 0
  fi

  if [ ! -e "$1" ]; then
    return 0
  fi

  local SAN=$(openssl x509 -in "$1" -noout -ext subjectAltName | grep "DNS:" | xargs )
  local SUBJECT=$(openssl x509 -in "$1" -noout -subject | cut -d '=' -f 2- )
  local ISSUER=$(openssl x509 -in "$1" -noout -issuer | cut -d '=' -f 2- )
  local EXPIRATION=$(openssl x509 -in "$1" -noout -enddate | cut -d '=' -f 2- )
  local FINGERPRINT=$(openssl x509 -in "$1" -noout -fingerprint | cut -d '=' -f 2- )
  local SERIAL=$(openssl x509 -in "$1" -noout -serial | cut -d '=' -f 2- )

  echo
  echo "SAN         : $SAN"
  echo "Subject     : $SUBJECT"
  echo "Issuer      : $ISSUER"
  echo "Expiration  : $EXPIRATION"
  echo "Fingerprint : $FINGERPRINT"
  echo "Serial      : $SERIAL"
  echo
}

cert_update()
{
  local NEW_PEM="$1"
  local CURRENT_PEM="$2"
  local CURRENT_KEY="$3"
  local CHECK_FINGERPRINT=
  local LAST_FINGERPRINT_ERROR=/tmp/last_fingerprint_error.txt

  if [ -z "$NEW_PEM" ]; then
    log_error "No new PEM specified"
     return 1
  fi

  if [ ! -e "$NEW_PEM" ]; then
    log_error "New PEM does not exist [$NEW_PEM]"
    return 1
  fi

  if [ -z "$CURRENT_PEM" ]; then
    log_error "No curren PEM specified"
    remove_file "$NEW_PEM"
    return 1
  fi

  if [ -z "$CURRENT_KEY" ]; then
    log_error "No new current key specified"
    remove_file "$NEW_PEM"
    return 1
  fi

  # Compare if there is an existing cert, else update in any case
  if [ -e "$CURRENT_PEM" ]; then

    # Get Fingerprints
    local FINGER_PRINT_UPD=$(openssl x509 -in "$NEW_PEM" -noout -fingerprint -sha256 | cut -d '=' -f 2)
    local FINGER_PRINT=$(openssl x509 -in "$CURRENT_PEM" -noout -fingerprint -sha256 | cut -d '=' -f 2)

    if [ "$FINGER_PRINT" = "$FINGER_PRINT_UPD" ]; then
      remove_file "$NEW_PEM"
      return 1
    fi
  fi

  # Get public key hash of updated cert and current key
  local PUB_KEY_HASH=$(openssl x509 -in "$NEW_PEM" -noout -pubkey | openssl sha1 | cut -d ' ' -f 2)
  local PUB_PKEY_HASH=$(openssl pkey -in "$CURRENT_KEY" -pubout | openssl sha1 | cut -d ' ' -f 2)

  # Both keys must be the same when matching certificate for existing key
  if [ "$PUB_KEY_HASH" = "$PUB_PKEY_HASH" ]; then

    echo
    echo "Certificate Update"
    echo "------------------"
    show_cert "$NEW_PEM"

  else

    if [ -e "$LAST_FINGERPRINT_ERROR" ]; then
      CHECK_FINGERPRINT=$(cat "$LAST_FINGERPRINT_ERROR")
    else
      CHECK_FINGERPRINT=
    fi

    if [ "$CHECK_FINGERPRINT" = "$FINGER_PRINT_UPD" ]; then
      log_debug "key and cert did not match again"

    else
      log_error "Certificate does not match key --> Not updating certificate"

      echo "NEW"
      echo "---"
      show_cert "$NEW_PEM"

      echo "OLD"
      echo "---"
      show_cert "$CURRENT_PEM"
    fi

    remove_file "$NEW_PEM"

    # Remember hash of last cert that did not match
    echo "$FINGER_PRINT_UPD" > "$LAST_FINGERPRINT_ERROR"
    return 2
  fi

  # Update certificate
  cp -f "$NEW_PEM" "$CURRENT_PEM"
  remove_file "$NEW_PEM"

  log_debug "Copying updated certificate [$NEW_PEM] -> [$CURRENT_PEM]"

  notifiy_applications

  return 0
}

check_cert_download()
{
  # Downloads certificate from server (usually a CertMgr server)
  # Returns 0 if updated
  # All other cases return an error

  local SERVER_KEY=$1
  local SERVER_CERT=$2
  local CERTMGR_HOST=$3
  local HOST_NAME=$4

  if [ -z "$CERTMGR_HOST" ]; then
    return 1
  fi

  if [ ! -e "$SERVER_KEY" ]; then
    log_debug "No key found when checking CertMgr server"
    return 2
  fi

  log_debug "Checking for certificate update on [$CERTMGR_HOST] for [$HOST_NAME]"

  # Just in case remove the template file
  remove_file "$TMP_UPD_PEM_FILE"

  # Check for new certificate
  openssl s_client -servername $HOST_NAME -showcerts $CERTMGR_HOST:443 </dev/null 2>/dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > "$TMP_UPD_PEM_FILE"

  if [ ! "$?" = "0" ]; then
    log_error "Cannot retrieve certificate from CertMgr server [$CERTMGR_HOST]"
    remove_file "$TMP_UPD_PEM_FILE"
    return 3
  fi

  if [ ! -s "$TMP_UPD_PEM_FILE" ]; then
    log_error "No certificate returned by CertMgr server"
    remove_file "$TMP_UPD_PEM_FILE"
    return 4
  fi

  cert_update "$TMP_UPD_PEM_FILE" "$SERVER_CERT" "$SERVER_KEY"

  remove_file "$TMP_UPD_PEM_FILE"
  return 0
}

check_import()
{
  if [ -z "$IMPORT_PEM_FILE" ]; then
    return 0
  fi

  if [ ! -e "$IMPORT_PEM_FILE" ]; then
    return 0
  fi

  # Create import password if not present yet
  if [ -n "$IMPORT_PASSWORD_FILE" ]; then
    if [ -e "$IMPORT_PASSWORD_FILE" ]; then
      log_debug "Import password file [$IMPORT_PASSWORD_FILE] already exists"
    else
      openssl rand -base64 32 > "$IMPORT_PASSWORD_FILE"
      log_space "New import PEM password: $(cat "$IMPORT_PASSWORD_FILE")"
    fi
  fi

  # Check for new key. Call ignores error if no key found. but prints info
  openssl pkey -in "$IMPORT_PEM_FILE" -passin pass:$(cat "$IMPORT_PASSWORD_FILE") -out "$TMP_UPD_PEM_FILE" >/dev/null 2>/dev/null

  if [ "$?" = "0" ]; then

    if [ ! -s "$TMP_UPD_PEM_FILE" ]; then
      log_debug "No new import key found in PEM"
    else
      cp -f "$TMP_UPD_PEM_FILE" "$SERVER_KEY"
      log_space "Private key updated!"
    fi
  else
    echo "Info: No private key found in PEM"
  fi

  remove_file "$TMP_UPD_PEM_FILE"

  # Check for new certificate
  openssl crl2pkcs7 -nocrl -certfile "$IMPORT_PEM_FILE" >/dev/null 2>/dev/null | openssl pkcs7 -print_certs > "$TMP_UPD_PEM_FILE" >/dev/null 2>/dev/null

  if [ ! "$?" = "0" ]; then
    log_error "Cannot get new certificate"
  fi

  if [ ! -s "$TMP_UPD_PEM_FILE" ]; then
    log_debug "No certificate to import"
   else
    cert_update "$TMP_UPD_PEM_FILE" "$SERVER_CERT" "$SERVER_KEY"
  fi

  remove_file "$TMP_UPD_PEM_FILE"
  remove_file "$IMPORT_PEM_FILE"
}

check_import
check_cert_download "$SERVER_KEY" "$SERVER_CERT" "$CERTMGR_HOST" "$HOST_NAME"

