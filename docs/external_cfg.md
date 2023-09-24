---
layout: default
title: "ACME HTTP-01 Challenges without port 80"
nav_order: 1
parent: "Integrations"
description: "ACME HTTP-01 Challenges without port 80 open on Domino"
has_children: false
---


# ACME HTTP-01 challenges without HTTP port 80 open on Domino

**ACME HTTP-01** challenges always use **HTTP port 80** for each certificate request. This request can be redirected. But the first contact is always on **port 80**!

If Domino is located behind a load-balancer, reverse proxy or similar configuration, port 80 might be already handled earlier in the inbound connection path.  

**HTTP-01 challenges** can be confirmed by any Domino server accepting challenges in your Domino domain. All ACME challenges could be even redirected to one central server in your environment.  
ACME allows redirects to any target server on port 80 or 443.

Note: This is supported even for different internet domains and the certificate of the target server is not validated.

## Redirecting HTTP to HTTPS with special redirect for ACME challenge

In a gateway scenario, this would allow the external gateway to redirect all standard traffic to HTTPS.  
**ACME HTTP-01 challenges** could be directed directly to the CertMgr server.

Domino only receives HTTPS requests and the **ACME HTTP-01 challenge** is redirected to the CertMgr server also on HTTPS (port 443).

The following example shows the principle using an NGINX configuration.  

### NGINX configuration example

- Redirect ACME HTTP-01 challenges to a central CertMgr server.
- Redirect all other HTTP requests to HTTPS

```
    # Port 80 is redirected to 443. Only ACME challenges are redirected to CertMgr server.

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;

        location /.well-known/acme-challenge/ {
            return 301 https://certmgr.acme.com$request_uri;
        }

        location / {
            return 301 https://$host$request_uri;
        }
    }
```

