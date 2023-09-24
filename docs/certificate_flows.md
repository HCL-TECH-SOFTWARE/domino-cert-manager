
# CertMgr Certificate Flows

CertMgr is supports multiple certificate flows. The leveraged flow depends on the server environment.
All type of certificates can be combined and offer the same type of operations like creating an exportable key.
For example it is explicitly supported to create an exportable key for a ACME requested wild card certificate, which can be used outside Domino.


# Import existing Certificate

Existing Certificates can be imported either via Notes client(requires 12.0.1+ client or template) or Domino server.

The certificate file can be one of the following formats

- PEM (Text base format)
- PKCS12 (P12, PFX)
- KYR File format (Legacy IBM key format)


## Import via Notes client

- Starting with Notes 12.0.1 the import action opens an import dialog.
- Imported TLS credentials cannot be exported unless marked as exportable with a strong export password.

Important: Client side imported TLS credentials are encrypted for the servers selected **before** invoking the import operation.


## Import via Server console command

Alternatively TLS Credentials can be imported via server command.
This can specially useful to import existing server certificates in KYR file format.

All server side import operations by default encrypt the TLS Credentials document for the current server and enable the TLS Credentials document.


# Manual Flow

The manual flow is intended for corporate or external certificates, which require a Certificate Signing Request (CSR).
This request flow is fully automated and does not require any external tools like OpenSSL or the command-line Domino kyrtool.


## Operations and Actions

- Specify certificate information like hostname, organization etc.
- Specify the server who should be allowed to use the TLS Credentials ("Servers with access" field).
- Create private and CSR
- Send CSR to CA of your choice (Microsoft, Internet CA like DigiCert, ..)
- Receive certificate from CA
- Paste Certificate into document and let CertMgr merge certificates


# Micro CA Certificate

Domino 12.0.1 introduces a new Micro CA.
The Micro CA has been improved in Domino 12.0.2 to allow exportable private keys and generates MicroCAs valid for 10 years in stead of 1 year.

A MicroCA is mainly intended for internal testing purposes. But can also be useful for a not user facing certificate behind a secure reverse proxy or load-balancer.

Once a Micro CA is created the request is a one step operation:

- Specify server hostname and servers with access
- Select Micro CA
- Submit the request

Beginning with Domino 12.0.2 new default Micro CA is created when not Micro CA is selected.


## Create Micro CA

In Domino 12.0.1 first switch to the **Certificate Authority** view and create a new Micro CA

- Specify a name for the CA
- Specify key type and length/curve
- Save the document
- CertMgr will automatically create the Micro CA and set the status to **Enabled** 

Once the Micro CA is enabled, the CA can be used for requests.
The Micro CA does currently not support intermediate certificate.
But an admin can create multiple CAs with different names and key types


# Let's Encrypt / ACME Certificates

CertMgr supports **ACME HTTP-01** and **ACME DNS-01** request flows for web server certificates.
The most commonly used provider is Let's Encrypt.

A request operation requires a challenge confirmation to proves the ownership of the server or domain.
The ACME protocol requires an outgoing HTTPS connection (directly or via proxy connection).

Challenge confirmation requires either and inbound HTTP connection or a DNS API to write the provided challenge into a **DNS TXT** record.


## ACME HTTP-01 Challenges

ACME HTTP-01 requests require no integrations and work out of the box as long HTTP inbound connections are allowed.

ACME follows HTTP and HTTPS redirect targets (port 80 and 443 only).
Any Domino 12.0.1 server can confirm HTTP-01 challenges by retrieving the private part of the challenge from cerstore.nsf on the CertMgr server.

## ACME DNS-01 Challenges

ACME DNS-01 challenges verify the ownership of the domain. This allows wild-card requests.
For DNS-01 TXT API integrations refer to available integrations in this repository.

## ACME Request flow

The following summary is a simplified flow. For details refer to [ACME RFC8555](https://datatracker.ietf.org/doc/html/rfc8555).

- Specify an ACME account, SAN names and submit the request
- The first request creates a new account key (either RSA or ECDSA) and registers an account
- CertMgr indicates which SANs are requested via ACME protocol
- The ACME provider offers **HTTP-01** and **DNS-01 challenge** requests options
- According to the configuration CertMgr either selects **HTTP-01** or **DNS-01** challenges
- For a **HTTP-01** CertMgr retrieves the challenge key and confirmation value
- For **DNS-01** challenges CertMgr leverages a configured DNS TXT API integration to store the value in a **DNS TXT** record 
- Once the challenge is in place CerMgr confirms the challenge to continue the flow
- A CSR is created and send to the ACME provider to retrieve the certificate chain
- CertMgr completes the received chain with a trusted root stored in a Trusted Root document and stores the result in the TLS Credential document
- Finally CertMgr verifies the certificate chain and updates the status.
