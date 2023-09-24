---
layout: default
title: "Concept & Overview"
nav_order: 1
description: "Domino 12 certificate management & integrations"
has_children: true
---

[Quickstart](quickstart.md){: .btn }
[View it on GitHub](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager){: .btn }


# Domino Certificate Manager (CertMgr)

HCL Domino 12 introduced a new server task and Domino domain wide database **certstore.nsf**, which replaces the old KYR file approach inherited from IBM.
The new CertMgr dramatically simplifies certificate operations and allows you to perform all certificate operations directly from a modern UI.
All CertMgr operations are centrally managed on your designated CertMgr server and are replicated to all servers in your domain.


## TLS Credentials

Keys, certificates, intermediates and the root certificate are stored in a single document in [PEM format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail) along with all information about the certificate and key.
The new format is referenced as "TLS Credentials" and the PEM based storage and replaces the proprietary KYR file format.

PEM is a text based industry wide used standard to represent certificate and key information. It can be easily exported and imported and used in any other application.


## Secure storage of private keys inside the TLS Credentials document

Private keys are stored in an item in the TLS Credentials documents. The private key is safely encrypted using a specially designed encryption.
An operations key is created to encrypt the data. This key is encrypted with the public key of the CertMgr server and all servers and all servers configured in "**Servers with access:**".
The private key cannot be exported and is only intended for CertMgr operations and the designated servers with access. 


## Exportable keys

Domino 12.0.1 introduced the concept of an exportable key, which is stored encrypted in PEM format in each TLS Credentials document.
The key is created by an admin **before** invoking a certificate operation and is protected with a password, which by design requires a strong password to protect the private key.
Any administrator with access to the document and the password, can decrypt the password.

The key along with the certificates are text based (PEM) and could be copied from the TLS credentials document.

For convenience a new export UI has been implemented in Notes 12.0.1 to allow export in PEM and PKCS12 format (aka P12 / PFX format).
To ensure end to end secure storage of private keys, the export always requires a strong password.
Exportable keys can be used in all flows described below (exportable keys for the MicroCA flow require a Domino 12.0.2 server or higher).


## Export/Import operations

In contrast to all other operations, export operations and also creating exportable keys are **client side operations**.
This means the client will encrypt and decrypt the private key. The client encrypts the private key with the public key of the CertMgr server and all servers with access automatically.

Because the **encryption is a one way operation** for the client, servers with access have to be added **before** the import operation!
The exportable key in PEM format is only intended for export operations. The password is only known by the administrator and never stored inside a TLS Credentials document.


# Trusted roots
Trusted roots are stored in separate documents also leveraging the text based PEM format.
To import a new trusted root **create** a new trusted root document, **paste** the certificate in PEM format and **submit** the request to the CertMgr server via action button.

Trusted roots are used for multiple purposes:

- Certificate chain completion when importing certificates
- Defining trusted roots a TLS Credential document trusts (by selecting the trusted root on the Keys and Certificates tab in the TLS Credentials document
- Provide trusted roots for Domino applications like CScan and OIDC/OpenID starting with Domino 12.0.2


## Certificate chain completion

Most CAs don't return the root certificate. In most cases the root certificate has to be manually requested from the CA and should be verified.
Certstore provides a trusted root store, which is automatically used to complete certificate chains during import and manual certificate request flows.
Import the trusted root into **certstore.nsf** before using a manual or import flow.


# Use cases and certificate flows

There are distinct use cases with different certificate flows depending on the certificate authority (CA) used.


## Import existing certificates

An existing key and certificate chain creates outside of Notes/Domino can be imported directly into a new TLS Credentials document starting with Notes 12.0.1.
The import supports PEM, PKCS12 (P12, PFX) and KYR.

For security reasons an encrypted format is recommended to protect the private key when copied to an administrator workstation.
The transport to the Domino server in the TLS Credentials document is always protected, because the client already performs the encryption operation for the private key as described earlier.
The import operation is always a client side operation performed on the Notes client.
To import a key along with the certificate chain leverage the UI in the TLS Credentials form.


## Manual certificate flow

The manual certificate flow is probably the most widely used way to request certificates. In contrast to the import process the private key never leaves Domino and is only decrypted when used by a server (TLS Cache).

- Specify host names (SANs) and servers with access and the desired key type and len/curve (RSA / ECDSA)
- Submit the request to the CertMgr server via action button to create the private key and a CSR (Certificate signing request)
- After CertMgr processed the request copy the CSR, which is also a text based PEM format, and send it to a Certificate Authority (CA)
- A CA processed the CSR to create a certificate and usually provides the certificate and certificate chain (intermediate certificates)
- Paste the certificates into **certstore.nsf** (action button) and let CertMgr process the request to merge the certificate and intermediate certificates with the private key


## Let's Encrypt / ACME

The ACME protocol (defined in RFC 8555 ) allows to requests certificates using a simple and automated flow to request certificates. The most commonly used and most well known ACME CA is Let's Encrypt.
Let's Encrypt provides free, commonly trusted certificates. But there are also other free CAs like Buypass, ZeroSSL and SSL.com, which are fully supported by CertMgr.
ACME might be even used in corporate environment to automatically request certificates in an intranet environments.  
In all different use cases the ACME protocol flow is used to request the certificate and requires a validation of the request using a so called "challenge".
CertMgr supports the two most commonly used challenge types: HTTP-01 and DNS-01.


### ACME HTTP-01 Challenges

The HTTP-01 challenge is most commonly used challenge, with a very simple flow.
- The ACME server provides a challenge secret and a request key to the requesting CertMgr server
- Once the CertMgr server confirms the challenge is in place, the ACME server tries to verify the challenge over port 80 on a well known URL.
- Services like Let's Encrypt query the challenge from multiple network points and will validate all servers listed for all provided DNS names requested in the CSR
- The Domino HTTP task has a build-in ACME extension to detect the challenge, lookup the challenge secret in certstore.nsf on the CertMgr server and automatically replies to the challenge.

By design the challenge is stored in **certstore.nsf** and any Domino server can confirm any challenge.  
This is specially interested for services located behind a load-balancer serviced on multiple Domino servers.


### ACME DNS-01 Challenges

In contrast to **ACME HTTP-01** challenges, *ACME DNS-01** challenges don't require any inbound connection. The validation is leveraging a DNS TXT record added to the authoritative DNS server for the domain requested containing a challenge secret provided by the ACME protocol, similar to the challenge provided in the HTTP-01 flow.
Storing and removing the challenge requires a DNS integration which allows your CertMgr server to automatically write the challenge information into a DNS TXT record.
This repository contains DNS TXT integration for the most commonly used DNS providers. CertMgr provides a very flexible interface creating additional integrations, which can be exported and imported using the DXL standard.
Once a DNS TXT API is in place a DNS provider document can be created to define DNS-01 challenge operations for a domain. All requests for this domain will automatically use a **ACME DNS-01** instead of a **ACME HTTP-01** challenge.


## Using a MicroCA Certificate

The Domino MicroCA is **mainly designed for internal test environments** and to ensure TLS encryption at first start-up when setting up your first server leveraging OneTouch setup (OTS).
A MicroCA certificate might be also used as a local certificate behind a secure reverse proxy terminating the TLS encryption to ensure end to end encryption in the back-end.

The trusted root of the CA document can be imported into the trust store of a browser or reverse proxy to establish a trust.

Starting with Domino 12.0.2 the root certificate created is now 10 years instead of the initial 1 year.
In addition the MicroCA supports the exportable key concept beginning with Domino 12.0.2.

The MicroCA flow is a simple one step process

- Specify the host names (SANs) key format and submit the request
- CertMgr just certifies just certifies your key with the requested certificate information. No CSR is needed in this flow.

Beginning with Domino 12.0.2 a new Domino MicroCA is automatically created, if no MicroCA is specified.
In Domino 12.0.1 or if multiple MicroCAs are required, the MicroCA document needs to be created before requesting the certificate.


## TLS Cache

A new TLS cache replaces the old KYR file cache and works hand in hand with the new CertMgr database, getting it's keys and certificates from the local **certstore.nsf** on each server for all internet tasks (http, imap, pop3, smtp, ldap -- including outbound connections).
The new cache fully supports RSA and ECDSA, the more modern and more efficient elliptic curve standard.. The cache is completely redesigned and understands wildcard certificates. In contrast to the older cache, the new cache automatically detects new and update TLS Credentials and immediately refreshes the TLS cache on the fly.
