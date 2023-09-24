# Domino Certificate Manager

## Introduction

HCL Domino 12 introduced a new server task and Domino domain wide database **certstore.nsf**, which replaces the old KYR file approach inherited from IBM.
The new CertMgr dramatically simplifies certificate operations and allows you to perform all certificate operations directly from a modern UI.
All CertMgr operations are centrally managed on your designated CertMgr server and are replicated to all servers in your domain.

This GitHub repository complements the official documentation [Domino V12 Certificate Manager](https://help.hcltechsw.com/domino/12.0.2/admin/secu_le_using_certificate_manager.html)
and provides Let's Encrypt / ACME DNS-01 Challenge integrations for well-known DNS providers.

In general CertMgr supports multiple flows. But one of the key content of this repository is dedicated to ACME DNS-01 integrations.

- **Manual Flow** (create a key, CSR, import certificates from an external CA)
- **Imported keys & certificates** from other CAs
- Integrated **Domino MicroCA** to create certificates for test/setup (or certificates used in the back-end for example behind a load-balancer)
- **Let's Encrypt / ACME** certificates


# Introduction and background ACME DNS-01 and DNS API

The ACME protocol used by Let's Encrypt and other providers mainly supports two challenge types to verify certificate requests

- HTTP-01
- DNS-01


## ACME HTTP-01 Challenges

This basic challenge type is commonly used and very easy to use interface without any special considerations or integration.

The only important requirement is an inbound connection to port 80.
The request for the well-known URL must be available unauthenticated

Example:
```
http://<YOUR_DOMAIN>/.well-known/acme-challenge/<TOKEN>
```

- Port 80 must be open
- Port 80 can be redirected to port 443 if the server already has a certificate to allow incoming connections to be accepted ( HTTPS does not need a valid certificate to accept the challenge request)
- You have to make sure all servers configured in DNS must be able to reply to the challenge. The servers must be reachable and CertMgr and the DSAPI filter to reply to the challenge must be enabled.
- This requirement includes all servers behind a load-balance, because the request might be routed to any of the servers
- Let's Encrypt checks the challenge more than once from different network points

For troubleshooting **ACME HTTPS-01** challenges see [Troubleshooting ACME HTTP-01 challenges](docs/troubleshooting_acme_challenges.md).


## ACME DNS-01 Challenges

DNS-01 challenges are more flexible but also more complex to setup method to validate your ACME requests:

- Your DNS provider needs to support an automated way to update a DNS TXT record (e.g. `_acme-challenge.<YOUR_DOMAIN>`)  for your domain to allow challenge validation. This is usually a modern REST API.
- Those REST APIs authentication usually is token or user/password based
- Because the validation confirms the ownership/control over DNS, this challenge type also allows to requre wildcard certificates

For details check the [Challenge Types](https://letsencrypt.org/docs/challenge-types/) documentation on the Let's Encrypt website.


## ACME DNS-01 API TXT Integration

This repository contains DNS TXT provider API integrations for **ACME DNS-01** providers

For [Let's Encrypt](https://letsencrypt.org/) and other ACME DNS providers supporting **ACME DNS-01** challenges, the ACME protocol requires `DNS TXT` records to be added to the requested DNS domains.  
CertMgr supports **ACME DNS-01** flows automating DNS TXT creation and deletion integrating with DNS providers with DNS API integrations.  

Most integrations today leverage modern REST interfaces with JSON payload which can be configured using the HTTP/HTTPS requests in combination with formula language (low code approach ).  
This is the preferred integration option.  But CertMgr also support script based (e.g. shell script) integrations or invoking Lotus Script or Java agents if the HTTP.

You will also find information about other ACME providers tested by HCL and the community and other useful information.

DNS provider configurations are stored in `DXL` format which is an exported Notes document that can be imported into the `certstore.nsf` database to obtain the settings required for enabling the Domino Certificate Manager to communicate with the vendor specific DNS-API.

After importing the DXL document more detailed information can be found inside of the newly created DNS provider configuration document.


## Important notes

DNS plays a very important role in corporate IT security!
Be aware of the following recommendations

- Ensure your DNS authentication configuration works reliable and is secure.
- Narrow down access for tokens to what you actually need, if your provider supports it : DNS TXT add/update capabilities for a given domain
- If your DNS provider does not support a sufficient secure mechanism, you can create CNAME delegation from your provider to a validation (sub)domain at another provider


## CNAME validation

Delegation via CNAMEs is commonly used and can help if your provider does not support DNS TXT record automation. In many enterprise environments using a validation domain might be the only way to use DNS-01 challenges. However you need DNS CNAME records available for your servers.

However CNAME validation works for wildcard certificate validation and even for sub-domain wildcard certificate validations

For more details about CNAME validation check the following Let's Encrypt document [Onboarding Your Customers with Let's Encrypt and ACME](https://letsencrypt.org/2019/10/09/onboarding-your-customers-with-lets-encrypt-and-acme.html).


# Available DNS provider integrations

Most DNS API integrations are modern REST interfaces and can be defined using the CertMgr HTTP request (low code) approach.

All DNS provider configurations are stored in a separate directory.
For REST basted interfaces usually a single configuration document is needed.
For command line interfaces usually shell scripts are invoked and need to be installed on your server.
Those shell scripts are added as attachments to the DXL document or can be used directly from git.

See list [Available DNS provider integrations](docs/dns_providers.md) for details.


# Available ACME providers

Let's Encrypt is the most widely used ACME based certificate service.
But there are other provides available as well.

See the current list of  [ACME providers](docs/acme_providers.md) for details.

# Support

DNS provider configurations are maintained by the HCL Domino community on best-effort basis. 
Customers are requested to submit pull requests for other DNS providers they have created an integration for.
