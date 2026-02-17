

delim()
{
  echo "--------------------------------------------------------------------------------"
}

header()
{
  echo
  echo
  delim
  echo "$@"
  delim
  echo
  echo
}


header "Generate CA ECDSA Key"

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -pkeyopt ec_param_enc:named_curve -out ca_key.pem

# openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ca_key.pem

header "Sign CA Key to create a CA certificate"

openssl req -x509 -new \
    -key ca_key.pem \
    -sha256 \
    -days 3650 \
    -out ca_cert.pem \
    -subj "/C=DE/O=NashCom/CN=NashCom ECDSA Root CA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "subjectKeyIdentifier=hash"


header "Create a user private ECDSA key"

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -pkeyopt ec_param_enc:named_curve -out user_key.pem

# openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out user_key.pem

header "Generate CSR for the user specified using the user's private key to sign"

openssl req -new \
-key user_key.pem \
-out user_smime.csr \
-subj "/C=DE/O=Example/CN=Max Mustermann/emailAddress=max@example.com" \
-addext "keyUsage=digitalSignature,keyEncipherment" \
-addext "extendedKeyUsage=emailProtection" \
-addext "subjectAltName=email:max@example.com"


header "Print out the CSR"

openssl req -in user_smime.csr -text -noout


header "Certify the user CSR using the CA's private key"

openssl x509 -req \
    -in user_smime.csr \
    -CA ca_cert.pem \
    -CAkey ca_key.pem \
    -CAcreateserial \
    -out user_smime_cert.pem \
    -days 825 \
    -sha256 \
    -copy_extensions copy # this is really dangerous. You should always verify the extensions specified!


header "Print user S/MIME X509 cert"

openssl x509 -in user_smime_cert.pem -noout -text

header "Create a simple test message"

echo "The yellow fox jumps over the Lotus tree" > mail.txt
cat mail.txt

header "Sign message with X509 S/MIME key"

openssl smime -sign \
    -in mail.txt \
    -signer user_smime_cert.pem \
    -inkey user_key.pem \
    -certfile ca_cert.pem \
    -out mail_signed.eml


header "Verify signed message"

openssl smime -verify -in mail_signed.eml -CAfile ca_cert.pem

echo

