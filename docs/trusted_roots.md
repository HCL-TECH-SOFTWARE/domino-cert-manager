---
layout: default
title: "Trusted Roots"
nav_order: 4
parent: "Concept & Overview"
description: "Trusted Roots"
has_children: false
---

# Trusted Roots / Root CA Certs

Trusted roots are technically certificates where the CA signs it own key. The certificate has also some special extensions set, like the CA attribute and SelfSigned.
Storing them in a device or browser trust store makes them usable for validation.

A widely trusted certificate in all browsers and devices gets it's value from exactly this trust factor.
For internal devices where admins are in full control of the trust stores, an internal CA works in the same way.

Trusted roots always need to be in a local trust store to validate the certificate chain.
The complete certificate chain is starting at the **leaf certificate**, often contains **intermediate certificates** and ends in the **root certificate**.

It is recommended to store the complete certificate chain to be sure the last certificate is actually a root certificate.
Web servers do not need to send the root certificate for validation. The chain is always completed with root certificates from a **local trust store**.

But if the last certificate in a chain is not a root certificate, you can't really tell if all intermediate certificates are present.
This is the main reason CertMgr generates a warning that the last certificate in chain is not a root certificate.


## Where Trusted Roots used in CertMgr?

Trusted Roots are important for the following use cases:

- Validate the turst chain Outgoing TLS connections (e.g. Directory Assistance secure LDAPS connections)
- Validate the certificate chain for client certificate authentication
- Trusted root to be selected for Domino applications like (CScan/ICAP and OIDC)
- Auto complete certificate chains for all request and import flows

The last part is a convenience functionality to allow administrators to leave out the root certificate when importing certificate chains.
Also the ACME request flow benefits from the auto chain completion, because ACME CAs only send the leaf certificate and the intermediate certificates.


## How are Trusted Roots stored?

Trusted roots are stored in certstore.nsf.
Each trusted root is a separate document containing the PEM formatted certificate along with meta data, like name expiration, fingerprints.

Trusted roots are referenced by their SubjectKeyIdentifer in TLS Credentials documents and also OIDC and ICAP configurations.

A separate view for trusted roots shows all trusted roots. The view changed in Domino 12.0.2 to show the new **Usage categories** (OIDC, ICAP, etc.).

## Importing Trusted Roots

Importing Trusted Roots is a server side operation initiated on a client.

To import a trusted root, perform the following steps:

1. Create a new document
2. Paste the PEM based certificate
3. Submit the request to the server
