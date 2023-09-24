---
layout: default
title: "ACME Support"
nav_order: 3
parent: "Concept & Overview"
description: "ACME support, challenges and providers"
has_children: false
---


# ACME providers

## ACME protocol

The ACME protocol is defined in [RFC8739](https://tools.ietf.org/html/rfc8739). Let's Encrypt is the main provider and inventor of ACME based certificate issuing.

Let's Encrypt Production and Staging are included in `certmgr.ntf`. 
Additional providers can be added manually by specifying the ACME directory URL.
You find the directory URLs listed for all tested providers.

## Let's Encrypt Production

[Let's Encrypt Production](https://letsencrypt.org) is most commonly used free certificate provider.

### Main features

- RSA 4096 and ECDSA NIST P-384 support
- Wildcard certificates
- Valid for 90 days
- No registration required

Directory URL

```
https://acme-v02.api.letsencrypt.org/directory
```

## Let's Encrypt Staging

[Let's Encrypt Staging](https://letsencrypt.org/docs/staging-environment/) is intended for all type of test environments, not only for development. For new configurations Staging should always be your first test.

### Main features

- Designed for testing with higher certificate and error limits
- Default configuration included in `certstore.ntf`
- RSA 4096 and maximum ECDSA NIST P-384 support
- Wildcard certificates
- No registration required

Directory URL

```
https://acme-staging-v02.api.letsencrypt.org/directory
```


## bypass

[bypass](https://buypass.com/) a certificate provider from Norway offers free ACME based certificates and also commercial certificates.

### Main features

- RSA 4096 and ECDSA NIST P-256 support only
- But valid for 6 month!
- Wildcard certificates
- No registration required
- Own root CA
- Trusted root needs to be imported into `certstore.nsf`  
Import from here: https://www.buypass.com/security/buypass-root-certificates

Directory URL

```
https://api.buypass.com/acme/directory
```


## ZeroSSL

[ZeroSSL](https://zerossl.com) offers free ACME based certificates and also commercial certificates

### Main features

- RSA 4096 and maximum ECDSA NIST P-384 support
- Wildcard certificates
- Valid for 90 days
- Requires registration and External Account Binding configured for the account on CertMgr side
- No ACME account rollover
- Certificate root is Comodo
- Trusted root needs to be imported into `certstore.nsf`  
Import from Notes client cacerts.pem

Directory URL

```
https://acme.zerossl.com/v2/DV90
```
