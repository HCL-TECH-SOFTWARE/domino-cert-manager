---
layout: default
title: "Expired Let's Encrypt DST Root CA X3"
nav_order: 5
parent: "Concept & Overview"
description: "Expired Let's Encrypt DST Root CA X3"
has_children: false
---

# Expired Let's Encrypt DST Root CA X3

## Introduction

Let's Encrypt (in short: LE) is the most prominent and used free [ACME](https://datatracker.ietf.org/doc/html/rfc8555) based certificate provider.
They are providing an incredible valuable service to the community and doing a great job planning ahead for changes.

The LE root certificate expired in September 2021. Of course they planned ahead and a new root certificate in place in time to continue providing free certificates to the community.  
Still there are older devices which don't get their root certificates updated. Those are mainly older Android devices.

Therefore LE decided to keep their old root certificate in place to have the best compatibility for all type of devices.
If you are interesting in details, [DST Root CA X3 Expiration September 2021](https://letsencrypt.org/docs/dst-root-ca-x3-expiration-september-2021/) is a good summary with more detailed references in the article.

TLS/SSL testing tools like SSL Lab report the root as expired. But we haven't seen any device which can't handle the expired root certificate, because most devices short cut the chain and use a cross signed certificate chain.
There might be some special cases specially in the Java space for older JVMs which might not handle the certificate chain properly today.

**In general the best practice is to stay with the default chain of trust unless you really need or want to switch.**

Unless you made changes, there is no action needed in February.

## How to request the shorter certificate chain today

Domino CertMgr provides an option to request the alternate chain, if the new chain is required today.

Specify `/1` for `ACME Alternate Chain Suffix:` in a TLS Credentials document and request a new certificate by submitting the TLS Credentials document (menu action). This will request the newer, shorter chain.

## Default newer shorter chain starting February 8th, 2024

LE plans to [shorten the Let's Encrypt Chain of Trust](https://letsencrypt.org/2023/07/10/cross-sign-expiration.html) February 8th, 2024.
Starting from this day Domino CertMgr will automatically get the shorter certificate chain. **No action is needed** on the Domino CertMgr side.
CertMgr is prepared for this change, always imports the full chain of certificates provided by Let's Encrypt in the ACME protocol and completes the chain with the root certificate automatically.
This will continue to work and is what already happens when requesting the alternate chain today.

## If you did not change anything, there is nothing to change in February

If you did not change the suffix, there is nothing to do unless you want to keep the old certificate chain as long as you can in 2024.
In this very special case read the LE link in detail and see what strategy you might want to follow. 


## Remove the alternate suffix

**In case you changed the suffix**, remove the **ACME Alternate Chain Suffix** before the certificate is renewed the next time.
A best practice would be to renew the certificate today by submitting the TLS Credentials document, afterwards remove the suffix and save the document without submitting it again.

This will ensure CertMgr automatically uses the new chain once Let's Encrypt switches their default chain of trust.

