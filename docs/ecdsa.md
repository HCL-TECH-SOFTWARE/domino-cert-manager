---
layout: default
title: "ECDSA support"
nav_order: 2
parent: "Concept & Overview"
description: "ECDSA keys & certificates"
has_children: false
---


[ECDSA](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) cryptography is a more modern type of key and certificate.
Domino 12.0 fully supports ECDSA for Domino web server certificates in parallel to RSA technology.

ECDSA keys are much shorter than RSA keys of equivalent strength and generally offer improved performance over their RSA equivalents.

| ECDSA | RSA | AES |
| -------- | ------- | ------- |
| ECDSA NIST P-256 |  ~ 3072 bit RSA | ~ 128 bit AES |
| ECDSA NIST P-384 |  ~ 7680 bit RSA | ~ 192 bit AES |
| ECDSA NIST P-521 | ~ 15360 bit RSA | ~ 256 bit AES |


In contrast to the key length elliptic keys are specified by their curve.
The recommended curve today is ECDSA NIST P-256, which provides a good balance of performance and security.

When using an ECDSA key, Domino automatically selects the following two supported ciphers instead of the RSA ciphers:

| Name | Hex Code |
| -------- | ------- |
| TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 | 0xC02B |
| TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 | 0xC02C |


All modern browsers and devices support ECDSA keys and are considered as the new best practice.

For further details refer to this excellent blog post [ECDSA: The digital signature algorithm of a better internet](https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/).


