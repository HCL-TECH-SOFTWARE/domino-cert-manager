---
layout: default
title: "ECDSA support"
nav_order: 2
parent: "Concept & Overview"
description: "ECDSA keys & certficates"
has_children: false
---


[ECDSA](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) cryptography is a more modern type of key and certificate.
Domino 12.0 fully supports ECDSA for Domino web server certificates in parallel to RSA technology.

ECDSA keys are much shorter than RSA keys of equivalent strength and generally offer improved performance over their RSA equivalents.

- A 256 bit (NIST P-256) ECDSA key is generally considered to be equivalent in strength to a 3072 bit RSA key or a 128 bit AES key.
- A 384 bit (NIST P-384) ECDSA key is generally considered to be equivalent to a 7680 bit RSA key or a 192 bit AES key.
- A 512+ bit ECDSA key (NIST P-521) is generally considered to be equivalent to a 15360 bit RSA key or a 256 bit AES key.

In contrast to the key length elliptic keys are specified by their cruve.
The recommended curve today is ECDSA NIST P-256, which provides a good balance of performance and security.

When using an ECDSA key, Domino automatically selects the following two supported ciphers instead of the RSA ciphers.

- TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 (0xC02B)
- TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 (0xC02C)

All modern browsers and devices support ECDSA keys and are considered as the new best practice.

For further details refer to this excellent blog post [ECDSA: The digital signature algorithm of a better internet](https://blog.cloudflare.com/ecdsa-the-digital-signature-algorithm-of-a-better-internet/).



