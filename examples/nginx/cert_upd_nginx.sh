#!/bin/bash

# ----------------------------------------------------------------------
# NGINX certificate update script.
# Last updated: 31.12.2021 
# ----------------------------------------------------------------------

# Copyright 2021 HCL America, Inc.
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
# Deploys and updates certificates from remote server via SNI request querying certificates.
# The current certificate file is compared with the remote certificate.
# In case the certificate expriation changes, the certificate is updated and NGINX is reloaded.

# ----------------------------

CERTMGR_HOST=certmgr.acme.com
PEM_FILE=/etc/nginx/cert.pem
#HOST=www.acme.io

LOG_LEVEL=1

if [ -n "$1" ]; then
  PEM_FILE=$1
fi 

if [ -n "$2" ]; then
  HOST=$2
fi

# ----------------------------

log ()
{
  if [ "$LOG_LEVEL" != "1" ]; then
    return
  fi
  echo "$@"
}

check_cert_upd()
{
  local CERT_FILE=$1
  local HOST=$2
  local NEW_CERT_FILE=$CERT_FILE.new
  local OLD_CERT_FILE=$CERT_FILE.bak
  local LOCAL_EXPIRATION=
  local REMOTE_EXPIRATION=

  if [ -z "$CERTMGR_HOST" ]; then
    log "No CertMgr sever configured!"
    exit 1
  fi

  if [ -e "$NEW_CERT_FILE" ]; then
    rm -f "$NEW_CERT_FILE"
  fi

  # Get certificate via SNI request
  echo | openssl s_client -servername $HOST -showcerts -connect $CERTMGR_HOST:443  2>/dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > $NEW_CERT_FILE
  REMOTE_EXPIRATION=$(openssl x509 -enddate -noout -in "$NEW_CERT_FILE" | cut -d= -f2)

  # Check expiration of local PEM
  if [ -e "$CERT_FILE" ]; then
    LOCAL_EXPIRATION=$(openssl x509 -enddate -noout -in "$CERT_FILE" 2>/dev/null | cut -d= -f2)
  fi

  log

  if [ "$REMOTE_EXPIRATION" = "$LOCAL_EXPIRATION" ]; then
    log "Hostname   : $HOST"
    log "Expiration : $LOCAL_EXPIRATION"

  else
    log "Hostname   : $HOST"
    log "Remote     : $REMOTE_EXPIRATION"
    log "Local      : $LOCAL_EXPIRATION"

    if [ -z "$(echo $REMOTE_EXPIRATION | grep GMT)" ]; then
      echo "No new certificate found - Error cannot update certificate!"
      return 0
    fi

    # cp is the most reliable way here
    if  [ -e "$CERT_FILE" ]; then
      cp -f "$CERT_FILE" "$OLD_CERT_FILE"
    fi

    cp -f "$NEW_CERT_FILE" "$CERT_FILE"
    RELOAD_REQUIRED=true
  fi

  log

  if [ -e "$NEW_CERT_FILE" ]; then
    rm -f "$NEW_CERT_FILE"
  fi
}

RELOAD_REQUIRED=false

# Use local host name if not configured
if [ -z "HOST" ]; then
  HOST=$(hostname -f)
fi

check_cert_upd "$PEM_FILE" "$HOST"

# Reload NGINX to update certificate, if needed
if [ "$RELOAD_REQUIRED" = "true" ]; then

  if [ "$EUID" = "0" ]; then
    service nginx reload
  else
    sudo service nginx reload
  fi
fi

