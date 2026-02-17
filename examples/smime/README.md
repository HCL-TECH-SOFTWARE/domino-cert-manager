
# S/MIME CA end to end example


Domino CertMgr is intended for Web server certificates.
Because there have been questions about S/MIME e-mail certificates here is a simple end to end example how to:

- Create a simple Certificate Authority (CA)
- Create a private key for S/MIME
- Generate a Certificate Signing Request (CSR)
- Let the CA sign the CSR
- Use the certificate and key to create S/MIME certificate
- And finally validate the S/MIME message using the CA's root public key


In case you need e-mail certificates for Notes S/MIME which are public trusted, the CSR signing part is performed by an external CA.
The resulting key and certificate in PEM format should be merged into a single PEM file along with CA certificates:

- Private key
- Leaf certificate issued by CA
- Intermediate certificates (if available)
- Finally CA root public key

The order is important for importing S/MIME certificates into the Notes Client using the security dialog

If your certificates are returned in a different format then PEM, refer to [Howto convert cert formats](https://opensource.hcltechsw.com/domino-cert-manager/howto_convert/)


The example shows the whole process. The OpenSSL CA isn't a production ready CA.
In case you still want to use it, the key should be well protected and persisted.
The certificate operation part of this flow can be repeated.

Using your own local simple CA would only work if the other part trusts your CA.
When singing a S/MIME message the other side can add the root to it's trust store after validating the root CA fingerprint etc.

This example is mainly intended to help to understand the flow.



