
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


## Support

DNS provider configurations are maintained by the HCL Domino community on best-effort basis.
Customers are requested to submit pull requests for other DNS providers they have created an integration for.
