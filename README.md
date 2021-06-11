# Domino Certificate Manager DNS API Integration

## Introduction

This repository contains DNS TXT provider API integrations for [Domino V12 Certificate Manager](https://help.hcltechsw.com/domino/12.0.0/admin/secu_le_using_certificate_manager.html).

For [Let's Encrypt](https://letsencrypt.org/) and other ACME DNS providers supporting DNS-01 challenges, the ACME protocol requires `DNS TXT` records to be added to the requested DNS domains.  
CertMgr supports DNS-01 flows automating DNS TXT creation and deletion integrating with DNS providers with DNS API integrations.  

Most integrations today leverage modern REST interfaces with JSON payload which can be configured using the HTTP/HTTPS requests in combination with formula language (low code approach ).  
This is the prefered integration option.  But CertMgr also support script based (e.g. shell script) integrations or invoking Lotus Script or Java agents if the HTTP.


## How to use this repository

DNS provider configuraitons are stored in `DXL` format which is an exported Notes document that can be imported into the `certstore.nsf` database to obtain the settings required for enabling the Domino Certificate Manager to communicate with the vendor specific DNS-API.

After importing the DXL document more detailed information can be found inside of the newly created DNS provider configuration document. 


## Avialable providers

### Cloudflare

[Cloudflare](https://www.cloudflare.com) is providing free DNS services with a [DNS-API](https://api.cloudflare.com/).

#### Main features

- REST based DNS TXT interface 
- DNS service for registered domains
- TOTP for secure admin interface authentication
- DNSSEC


### Hetzner

[Hetzner](https://www.hetzner.com/) is a german based internet service provider providing free DNS services with a [DNS-API](https://dns.hetzner.com/api-docs/)

#### Main features

- REST based DNS TXT interface 
- DNS service for registered domains
- TOTP for secure admin interface authentication

## Support

DNS provider configurations are maintained by the HCL Domino community on best-effort basis. 
Customers are requested to submit pull requests for other DNS providers they have created an integration for. 
