---
layout: default
title: "DNS TXT API Integrations"
nav_order: 1
parent: "Reference"
description: "Available DNS provider integrations"
has_children: false
---


# Available DNS provider integrations

## Cloudflare

[Cloudflare](https://www.cloudflare.com) is providing free DNS services with a [DNS-API](https://api.cloudflare.com/).

### Main features

- DNS service
- DNSSEC support
- REST based DNS TXT interface
- 2FA for secure admin interface authentication

## Digital Ocean

[Digital Ocean](https://cloud.digitalocean.com) is providing free DNS services with a [DNS-API](https://developers.digitalocean.com/documentation/v2/)

### Main features

- DNS service registered domains and sub domains
- REST based DNS TXT interface
- 2FA for secure admin interface authentication

This service is very helpful in case you have an existing internet domain and want to delegate a sub domain to a provider with DNS TXT record API integration.  
It works in combination with CNAME validation for domains hosted at a different provider

## Hetzner

[Hetzner](https://www.hetzner.com/) is a German based internet service provider providing free DNS services with a [DNS-API](https://dns.hetzner.com/api-docs/)

### Main features

- DNS service
- REST based DNS TXT interface
- 2FA for secure admin interface authentication

## ACME-DNS

[ACME-DNS](https://github.com/joohoi/acme-dns) is an open source project providing an open source based ACME optimized DNS server

### Main features

- DNS designed for serving TXT records only for a validation sub domain
- REST based DNS TXT interface
- Intended for self hosting in combination with DNS CNAME delegation for your existing domains
- Ready to go Docker image


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


## Support

DNS provider configurations are maintained by the HCL Domino community on best-effort basis.
Customers are requested to submit pull requests for other DNS providers they have created an integration for.
