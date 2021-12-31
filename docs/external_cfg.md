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

# Deploying certificates outside Domino

As long Domino is your target application, key and certificate management is automated.  
Certificates and keys are automatically distributed in your Domain replicating `cerstore.nsf`.  
The TLS Cache on each server reloads the cache as soon a change is detected automatically.  

CertMgr is the recommended central certificate management for Domino 12 related configurations!  
Beginning with Domino 12.0.1 exportable TLS Credentials can be used for external applications as well.  
Once the private key is exported, certificates can be retrieved from CertMgr via HTTPS SNI requests.  

Certificate deployment outside Domino can be automated, leveraging all existing certificate management operations including ACME flows in CertMgr (HTTP-01 and DNS-01).

## Create an exportable key

Create an exportables key first. This key is stored in encrypted PEM format in the TLS Credentials document.  
You can either copy and paste it in PEM format or use the Notes 12.0.1 export functionality.  

Exporting the private key is a one-time operation in this flow.
Certificate renewals in CertMgr keep the existing key and only request new certificates.

In the following NGINX example the key is located here: `/etc/nginx/key.pem`

Beside copying the key, you also have to store the password  in `/etc/nginx/ssl_pw.txt`.
Ensure the file is owned by root and only root can read it (`chgmod 400 /etc/nginx/ssl_pw.txt`).

The key and the password is referenced in `/etc/nginx.conf`.

Note: A key without a certificate fails the NGINX configuration. Keep the TLS configuration commented out until the certificate is available. The NGINX configuration can be tested via `nginx -t`.

## Distributing certificates and chains

Once the certificate is available in `certstore.nsf` the certificate can be requested via SNI aware clients like **OpenSSL** command-line.  This request can be performed independent of DNS configuration! The SNI aware TLS handshake distincts between connected host and host requested.

Note: Make sure the server queried is listed in "**Servers with access:**" for the requested TLS Credentials requested!

### Example command line for OpenSSL

```
 echo | openssl s_client -servername www.acme.io -showcerts -connect certmgr.acme.com:443  2>/dev/null | sed -ne '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > cert.pem
```

This flow can be automated and allows to deploy and update certificates for existing keys.

### Example NGINX configuration with HTTPS and ACME redirect

Check [example configuration](../examples/nginx/nginx.conf) for details.

The first part of the example shows:

- Redirect ACME HTTP-01 challenges to a central CertMgr server.
- Redirect all other HTTP requests to HTTPS

The second part of the example shows a TLS configured site, using an exported private key from CertMgr protected with a password.

### Example NGINX certificate update script

Check the [example script](../examples/nginx/cert_upd_nginx.sh) for automating certificate deployments and updates.

The script assumes the default configured PEM file from the previous NGINX configuration `/etc/nginx/cert.pem` as the default value. It leverages `openssl` command line to retrieve and check the certificate.

