
# Anatomy of a TLS Credentials document

The TLS Credentials document replaces the KYR file format used in previous versions of Domino.
It is a more modern, standardized way to manage TLS SSL/Certificates and is the new recommended way to mange web server X.509 certificates Domino domain wide.
All components are stored in an industry standard text based format (PEM).

## TLS/SSL X.509 Web server certificate

In general a X.509 certificate consist of the following components:

- Private key
- Public key derived from the private key
- Leaf certificate matching the public key
- One or more intermediate certificates building a trust chain
- Root certificate 

## Concept of the exportable key

A private key is stored encrypted for the CertMgr server and all servers with access to the key.
The internal format **cannot be exported by design**.

In case the private key should be exportable, the key can be also stored exportable protected with a strong password, when the key is created.


## PEM Format

The PEM format wraps the binary DER format into a base64 encoded text format, which delimits separate components with BEGIN and END terminators for example `-----BEGIN CERTIFICATE-----`.
This allows to concatenate keys and certificates in a single file or text buffer.

Exportable keys in the TLS credentials document are also stored in PEM based encrypted format, protected with a strong password.

All CertMgr flows are based on the PEM based format.
Export and import functionality supports another widely used PKCS12 format (aka as P12 or PFX in Microsoft terms).

Additional new lines between certificate components are explicitly allowed.
But it is very important to keep the BEGIN/END strings of each component complete. This includes the number of dashes and the exact format!

PEM based certificates are displayed in the TLS Credentials document for your convenience and can be copied when the document is in read mode.

Decrypting the exportable private key requires the export password specified when creating the exportable key.

### Example PEM format

```
-----BEGIN CERTIFICATE-----
MIIBYDCCAQWgAwIBAgIQENLwGc48ZLPeP32BfuddyTAKBggqhkjOPQQDAjAfMRAw
DgYDVQQKDAdOYXNoQ29tMQswCQYDVQQDDAJDQTAeFw0yMzAyMTMyMjM1MTlaFw0z
MzAyMTQyMjM1MTlaMB8xEDAOBgNVBAoMB05hc2hDb20xCzAJBgNVBAMMAkNBMFkw
EwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE2r7f1xeLfJ21qjiFaJLuBXlBmbmFncxt
NktLFG5J0pUWmRqh3ZtDQau2NA4lwOPjAJ9cS375pkYiCc6pJiT5M6MjMCEwDgYD
VR0PAQH/BAQDAgIEMA8GA1UdEwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDSQAwRgIh
AP6w2uU27m9sCE6bUvmkjJ7HgPjC+ki3xqg2Zvw3MIMOAiEA0C6GzWvMZeL5KrHz
5+j0lzXd3O/v4OfO/ARYIdl+VQI=
-----END CERTIFICATE-----
```


## What is a self signed certificate

A classical self signed certificate consists of a key and a certificate without a Root CA.
Self signed certificates should be avoided, because they require an exception added to a web browser.

Specially Nomad Web leveraging web socket connections require fully trusted certificates.

The certificate must either be issues by a public trusted root certificate, which is already the local certificate store.
Or the trusted root for the specific certificate must be added to the local trust store.

Web browser vendors either leverage their local certificate store (for example Firefox) or use the operating system trust store (e.g. Microsoft Edge).
Depending on your environment a trusted root can be only added by an administrator. 



## TLS Credentials fields

This section describes the fields used in TLS Credentials documents and might be important for a deeper understanding or in case of own integrations like automating the manual flow.
The steps performed by an admin in the UI, can be also automated with for example a Lotus Script agent.
Beside the private key, which needs to be protected, all other fields use text based formats.


### PrivateKey

Encrypted private key only readable by assigned servers.
Binary encrypted format using an operations key, encrypted with all public server keys.

### PublicKey

PEM based public key matching the private encrypted key.

### PrivateKeyExportable

PEM based private key always encrypted using the password specified during key creation/import

### KeyChain

PEM based certificate chain including the trusted root (leaf, intermediate certificates and root).

### HostName

Subject Alternate Names (SANs) of the leaf certificate.
Multi value field in LMBCS (Lotus Multi Byte Character Set)

### HostnameIDN

SAN names in [Punycode](https://en.wikipedia.org/wiki/Punycode) format (ASCII encoding)
In case one or more SAN entries contain none ASCII charters, the Punycode format is also available.
The HostName field contains the international representation in human readable format.
The internal cache uses the Punycode format used for IDN domains (International Domain Names).

### KeyIdentifier

A subject key identifier is an unique identifier used as the internal key to reference a TLS Credentials document or a trusted root.

### Status

The status field controls CertMgr operations and triggers request processing.
The following main states are used.


| Value| Status     | Description |
| -----| ---------- | ----------- |
| D    |  Draft     | Draft state. Ignored by CertMgr server |
| O    |  Pending   | Request is submitted to CertMgr server for processing |
| I    |  Issued    | Certificate is issued |
| N    |  Renew     | Request for a new certificate requested, which will be processed by CertMgr server |
| R    |  Revoke    | Pending revoke operation submitted to CertMgr server used for ACME flow |
| K    |  Revoked   | Certificate revoked via ACME protocol |
| E    |   Error    | Certificate is in error state. Check ErrorText for detailed error message |
| W    |  Waiting   | Waiting for administrator in manual flow after key and CSR is created |
| A    |  Archived  | Certificate has been archived, because a new certificate has been issued. Archived certificates are only shown in the Archive view and are not loaded by the TLS Cache |
| X    |  Expired   | Certificate is expired|
| S    |  Update Server List| Request to re-encrypt the private key with an updated server list. Can be used for troubleshooting and manually request a re-encryption of the private key |

### StatusKeyfile

Status of the TLS Credentials document

| Value| Status            | Description |
| -----| ------------------| ----------- |
| 1    |  Green            | Certificate is valid, the certificate chain is complete|
| 2    |  Yellow (Warnings)| There are warnings for the certificate. For example: Missing trusted root, certificate is about to expire etc.|
| 3    |  Red (Errors)     | Critical error. Certificate cannot be used (e.g. no certificate or certificate not matching key)|

### ErrorText

Contains the human readable error text received by ACME protocol, LibCurl or CertMgr.

### KeyFileWarnings

Text list containing certificate warnings in human readable format

### KeyFileErrors

Text list containing certificate errors in human readable format

# Trusted Roots

Trusted roots are stored in separate documents are primary used for

- Configuring trusts for outgoing connections like LDAPS (Directory Assistance)
- Configuring trusts for incoming client certificate authentication

In addition trusted roots are used to auto complete chains in all certificate operations


# CA Certificates

The Domino Micro CA has been introduced in Domino 12.0.1 and has been enhanced in Domino 12.0.2 (10 years CA expiration instead of 1 year, support for exportable keys).

The Micro CA is a simple to use internal CA, which consists of a private key and a CA certificate.
The CA document stores certificate and key information in the same fields described for the TLS Credentials document.
The private key is encrypted for the CertMgr server only.


# Retrieve certificate chains from remote servers

If a certificate is not trusted, you might need to understand which certificate a remote server is using.
Downloading the certificate chain is important to understand which certificate chain a remote server uses.

The Notes/Domino JVM binary directory contains the keytool, which can be used out of the box to request certificates from a remote server.

```
jvm/bin/keytool -printcert -rfc -sslserver blog.nashcom.de:443
```

Most operating systems also ship the openssl command-line, which is the swiss army knife of all type of certificate operations including downloading certificate chains from remote servers.

```
openssl s_client -servername blog.nashcom.de -showcerts -connect blog.nashcom.de:443 </dev/null 2>/dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > chain.txt 
```


# Other useful commands and examples

## Display a public key

```
openssl ec -pubin -in ec.pub -noout -text

read EC key
Public-Key: (256 bit)
pub:
    04:c1:3d:98:98:2a:b3:f0:65:04:7b:63:3b:24:6f:
    71:f9:5d:6f:43:5d:96:7e:4d:bb:c9:17:43:89:7f:
    91:e4:2a:81:07:14:22:70:2a:cc:2f:b6:8f:e0:0d:
    37:2e:18:87:04:4c:b9:12:c1:8a:5e:42:c5:01:80:
    7c:24:f0:59:ae
ASN1 OID: prime256v1
NIST CURVE: P-256
```

## Display a private key

```
openssl pkey -in ec.key -noout -text

Private-Key: (256 bit)
priv:
    a1:b9:de:57:56:8e:e3:53:e5:74:6a:d7:4d:8a:91:
    cf:9e:82:ae:24:e1:d1:f2:c8:dd:d1:0c:9c:e4:88:
    a7:44
pub:
    04:c1:3d:98:98:2a:b3:f0:65:04:7b:63:3b:24:6f:
    71:f9:5d:6f:43:5d:96:7e:4d:bb:c9:17:43:89:7f:
    91:e4:2a:81:07:14:22:70:2a:cc:2f:b6:8f:e0:0d:
    37:2e:18:87:04:4c:b9:12:c1:8a:5e:42:c5:01:80:
    7c:24:f0:59:ae
ASN1 OID: prime256v1
NIST CURVE: P-256
```

## Display a CSR

```
openssl req  -in /tmp/csr.pem -noout -text

Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = DE, O = NashCom, CN = www.nashcom.de
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:74:22:22:0a:56:7e:aa:78:d3:62:f2:6f:16:e5:
                    5c:33:57:58:2e:6f:20:d2:af:fc:41:11:6c:5a:b1:
                    e0:c2:26:71:1b:a3:51:8b:5b:9b:3f:a2:15:16:c5:
                    d6:d2:c5:7f:9f:ad:4c:db:c2:0b:7e:dc:f9:d6:f1:
                    ca:58:72:99:c3
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        Attributes:
        Requested Extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:www.nashcom.de
    Signature Algorithm: ecdsa-with-SHA256
         30:45:02:20:41:d3:7d:5a:cf:13:11:b3:76:6e:91:7e:2e:29:
         9b:35:f8:2e:bc:dd:6c:5f:7d:c0:1d:e8:df:82:3d:95:75:3c:
         02:21:00:f3:30:ba:55:c1:19:86:2b:f9:14:43:ff:86:21:a4:
         09:ec:3f:38:ff:e8:28:42:cf:3d:02:8f:1c:a6:00:5e:cf
```

## Get public key from CSR

```
openssl req -in /tmp/csr.pem -noout -pubkey

-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEdCIiClZ+qnjTYvJvFuVcM1dYLm8g
0q/8QRFsWrHgwiZxG6NRi1ubP6IVFsXW0sV/n61M28ILftz51vHKWHKZww==
-----END PUBLIC KEY-----
```
