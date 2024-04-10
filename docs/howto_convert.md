---
layout: default
title: "Howto convert cert formats"
nav_order: 2
parent: "Howto"
description: "Howto convert cert files from and to PEM"
has_children: false
---

# Certificate formats

The most commonly two formats are PEM and PKCS12 today.
But there are other binary and text based formats used in the corporate world.
The most recommended format is the text based PEM.


## PEM

[PEM format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail) is the most common best to handle format.
It's a text format, which is basically a base64 encoded format with a header and footer.
It's very easy to transport and can be even pasted.

Most modern software supports PEM. The format is the standard format used in Domino CertMgr.
All certificates are stored natively in PEM. Only the internal key is stored encrypted in Domino internal format.
The exportable key is also stored in encrypted PEM format to allow standard based export flows without using any specific API.

A PEM file can contain private/public keys, leaf certificates, intermediate certificates and root certificates.

### Example PEM file

A PEM file always has exactly the shown begin and end markers and is usually printed with new lines.
It is very important to keep those begin and end markers unmodified!


```
-----BEGIN CERTIFICATE-----
MIICGzCCAaGgAwIBAgIQQdKd0XLq7qeAwSxs6S+HUjAKBggqhkjOPQQDAzBPMQsw
CQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJuZXQgU2VjdXJpdHkgUmVzZWFyY2gg
R3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBYMjAeFw0yMDA5MDQwMDAwMDBaFw00
MDA5MTcxNjAwMDBaME8xCzAJBgNVBAYTAlVTMSkwJwYDVQQKEyBJbnRlcm5ldCBT
ZWN1cml0eSBSZXNlYXJjaCBHcm91cDEVMBMGA1UEAxMMSVNSRyBSb290IFgyMHYw
EAYHKoZIzj0CAQYFK4EEACIDYgAEzZvVn4CDCuwJSvMWSj5cz3es3mcFDR0HttwW
+1qLFNvicWDEukWVEYmO6gbf9yoWHKS5xcUy4APgHoIYOIvXRdgKam7mAHf7AlF9
ItgKbppbd9/w+kHsOdx1ymgHDB/qo0IwQDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
AQH/BAUwAwEB/zAdBgNVHQ4EFgQUfEKWrt5LSDv6kviejM9ti6lyN5UwCgYIKoZI
zj0EAwMDaAAwZQIwe3lORlCEwkSHRhtFcP9Ymd70/aTSVaYgLXTWNLxBo1BfASdW
tL4ndQavEi51mI38AjEAi/V3bNTIZargCyzuFJ0nN6T5U6VR5CmD1/iQMVtCnwr1
/q4AaOeMSQ+2b1tbFfLn
-----END CERTIFICATE-----
```

## PKCS12

[PKCS12](https://en.wikipedia.org/wiki/PKCS_12) is often referenced as **.pfx** in the Microsoft world. The official standard extension is **.p12**
It is a binary format, which can contain multiple certificates and keys with lables (friendly name).
The format is a bit harder to deal with, but can be imported and exported into and from **certstore.nsf**


## Other formats


### DER

DER is a binary encoded format, which is basically PEM but binary encoded.


### PKCS7

PKCS7 is a text based format for holding certificate chains encoded into a single Base64 stream.
The format is less commonly used, but good to know about.


## Encryption standard used by Domino CertMgr

The **PEM** and **PKCS12** format both support encryption.  
The standard encryption algorithm is **AES-256-CBC with PBKDF2** for key derivation today.  
Standard used is the modern standard also used by OpenSSL 3.0.x.

Note: Older versions of OpenSSL can read the the newer standard, but will generate less secure encrypted files by default.

For Notes Client based export operations there is a legacy option in Notes 12.0.1 and higher to create a PKCS12 or PEM file.
The client will then use a lower encryption standard (often needed for Java and other applications).

But you can also easily convert those file using OpenSSL command as shown below and avoid the notes.ini which would create all your files in the legacy format.
The lower security should be only used if really needed. And the better option should be to convert to a legacy format only when needed.

```
PKCS12_EXPORT_LEGACY=1
```

OpenSSL 3.0 command line also supports a `-legacy` switch to fall back to older encryption standards.
In case an import isn't working in OpenSSL 3.x or if you need to export with encryption, you might need the `-legacy` switch.

See the [OpenSSL PKCS12 documentation](https://www.openssl.org/docs/manmaster/man1/openssl-pkcs12.html) for details.


## Convert between formats

**OpenSSL** is the standard command-line tool to convert between formats.

Only Java KeyStores require the Java keytool.
All other formats are handled by a OpenSSL command line.

Note: Java supports the PKCS12 format meanwhile and you should consider switching to PKCS12 instead where possible.


## PKCS12 to PEM

Converts PKCS#12 file (.pfx .p12) into Certs and Keys

```
openssl pkcs12 -in cert.pfx -out cert.pem -nodes
```


## DER binary to PEM

Converts binary DER cert file into PEM format

```
openssl x509 -inform der -in server.cer -outform pem -out server.pem
```


## PKCS7 DER binary encoded cert chain into PEM

Converts binary DER encoded cert chain into PEM format

```
openssl pkcs7 -print_certs -inform der -in certificate_chain.p7b -outform pem -out chain.pem
```

## PKCS7 PEM encoded cert chain into standard PEM

Converts PEM encoded cert chain into PEM format

```
openssl pkcs7 -print_certs -inform pem -in certificate_chain.pem -outform pem -out chain.pem
```


## PEM to PKCS12

Converts PEM Format into PKCS12 

```
openssl pkcs12 -export -out server.p12 -in cert.pem -inkey key.pem -passin pass:mypassword -passout pass:mypassword
```

Same conversion just for certificates without keys

```
openssl pkcs12 -export -nokeys -in cert.pem -out server.p12

```
