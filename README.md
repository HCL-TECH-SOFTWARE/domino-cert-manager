# Domino Certificate Manager DNS API Integration

## Introduction

This repository contains DNS TXT provider API integrations for Domino V12 CertMgr.

For Let's Encrypt and other ACME DNS providers supporting DNS-01 challenges, the ACME protocol requires `DNS TXT` records to be added to the requested DNS domains.  
CertMgr supports DNS-01 flows automating DNS TXT creation and deletion integrating with DNS providers with DNS API integrations.  

Most integrations today leverage modern REST interfaces with JSON payload which can be configured using the HTTP/HTTPS requests in combination with formula language (low code approach ).  
This is the prefered integration option.  But CertMgr also support script based (e.g. shell script) integrations or invoking Lotus Script or Java agents if the HTTP.


## How to use this repository

DNS provider configuraitons are stored in `DXL` format and can be imported directly into the `certstore.nsf` database.

Once the DXL document is imported, you find detailed documentation inside the new DNS provider configuration document. 


## Avialable providers

### Cloudflare

Cloudflare is one of the reference implementations.
The company is providing free DNS services with a very flexible and easy to use interface.

#### Main features

- REST based DNS TXT interface 
- DNS service for registered domains
- TOTP for secure admin interface authentication
- DNSSEC


### Hetzner

German based internet service provider providing free DNS services.  

#### Main features

- REST based DNS TXT interface 
- DNS service for registered domains
- TOTP for secure admin interface authentication


