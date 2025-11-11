---
layout: default
title: "DNS TXT API Integrations"
nav_order: 1
parent: "Reference"
description: "Available DNS provider integrations"
has_children: false
---

The following DNS provider integrations are available.
There is a separate directory containing the DXL files for each provider.
Import the DXL file into certstore.nsf using the Action menu `Import DXL`.
The imported document contains documentation for each provider.


# Available DNS provider integrations


## Cloudflare

[Cloudflare](https://www.cloudflare.com) is providing free DNS services with a [DNS-API](https://api.cloudflare.com/).

### Main features

- DNS service
- DNSSEC support
- REST based DNS TXT interface
- 2FA for secure admin interface authentication

[Download DXL](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager/blob/main/dns-providers/cloudflare/certstore_cloudflare.dxl)



## Digital Ocean

[Digital Ocean](https://cloud.digitalocean.com) is providing free DNS services with a [DNS-API](https://developers.digitalocean.com/documentation/v2/)

### Main features

- DNS service registered domains and sub domains
- REST based DNS TXT interface
- 2FA for secure admin interface authentication

This service is very helpful in case you have an existing internet domain and want to delegate a sub domain to a provider with DNS TXT record API integration.  
It works in combination with CNAME validation for domains hosted at a different provider

[Download DXL](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager/blob/main/dns-providers/digitalocean/certstore_digitalocean.dxl)



## Hetzner

[Hetzner](https://www.hetzner.com/) is a German based internet service provider providing free DNS services with a [DNS-API](https://docs.hetzner.cloud/reference/hetzner).
Starting November 2025 Hetzner moved their DNS interface to the [Cloud console](https://console.hetzner.com).
This update makes it possible to manage DNS domains in separate projects cloud use spearate API tokens per project. 

Until moved to the new console continue to use the existing legacy API.
As soon a DNS domain is migrated, the new API is required.


### Main features

- DNS service
- REST based DNS TXT interface
- 2FA for secure admin interface authentication


[Download DXL](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager/blob/main/dns-providers/hetzner/certstore_hetzner.dxl)



## ACME-DNS

[ACME-DNS](https://github.com/joohoi/acme-dns) is an open source project providing an open source based ACME optimized DNS server

### Main features

- DNS designed for serving TXT records only for a validation sub domain
- REST based DNS TXT interface
- Intended for self hosting in combination with DNS CNAME delegation for your existing domains
- Ready to go Docker image


[Download DXL](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager/blob/main/dns-providers/acmedns/certstore_acmedns.dxl)



## deSEC e.V.

[deSec](https://desec.io) is a free service provided by a registered non-profit organization based in Germany

### Main features

- DNS provider including modern DNS security features for a dedicated or a Dyn DNS domain
- REST based DNS TXT interface
- Can be used for dynamic DNS for dial-up IP addresses (mainly for testing)
- DNS entries can be specified via graphical interface or REST based DNS API

This project is specially interesting for admins startin with DNS-01 challenges.  
The configuration can be used from any server with outbound HTTPS connections.  
For home use with a dynamic IP also HTTP-01 challges should work.  


[Download DXL](https://github.com/HCL-TECH-SOFTWARE/domino-cert-manager/blob/main/dns-providers/desec/certstore_desec.dxl)



## Support

DNS provider configurations are maintained by the HCL Domino community on best-effort basis.
Customers are requested to submit pull requests for other DNS providers they have created an integration for.

