---
layout: default
title: "FAQ"
nav_order: 8
description: "Frequently asked Questions"
has_children: false
---


# How a trusted roots used?

I imported our Root Certificate into the CertStore successfully. 
Then I tried to import the intermediate certificate using the same process and Domino has a warning that it is not a Root certificate.
Does this matter? If it does, how do I get Domino to recognize the intermediate certificate?

The trusted roots are mainly designed for "root CA certificates".

Root certificates have multiple use cases in `certstore.nsf`. The main use case is to be the root certificate you trust.
The certificate chain is usually provided by the remote server. They might send the root as well, but the root needs to be in the local trust store to validate it.

Trusted roots are used to complete the chain when you import certificates or also in the ACME flow (for example Let's Encrypt) when you get the leaf certificate and the chain without the root from the ACME provider.
Storing intermediate certificates in the same way is allowed and you get the warning to show that this is not a root certificate. They still work and they are used to auto complete chains in all certificate flows.
But they are not actively involved in trust operations. That's why you get a warning.

The trusted roots in `cerstore.nsf` replace the additional root certificate in **kyr-files** for **TLS credentials** which are used for example when validating client certificates (HTTPS) or LDAPS outgoing connections.
They can be selected as trusted roots. In Trusted Roots in the Certificates/Keys tab.

In addition trusted roots from `certstore.nsf` can be used in **OIDC** configurations (`idpcat.nsf`) and also as trusted roots for CScan/ICAM in `cscancfg.nsf`.

So in summary: The warning is OK and now you know why there is a warning.


# Is creating a TLS credential from scratch using the CertStore "better" than Importing a TLS certificate from a KYR file or does it not matter?

Technically there is no "better" the certificates are the same and they are always stored in **PEM format**.
You can see them in clear text in the TLS Credentials document. 

Certstore only uses KYR an import format only. And never as a storage format. One of the design goals was to replace the "**kyr-file format**" with the standard PEM format. KYR is an old IBM format using two files. The KYR file itself is encrypted and the encryption key is stored in the STH file. 

The `.sth` file is just encoded and you can run a simple perl script to decode it.  When CertMgr reads a `.kyr` file it will always get the password from the .sth file with the same name. You don't need to specify it.

HCL recommends to use CertMgr and don't use KYR files any more. But the new TLS Cache has been implemented to be fully compatible to the old KYR cache and they are both enabled by default.
The TLS cache will be asked first. Only if not key is found, the old KYR file cache is asked. 

# How do I know if the HTTP task is using the TLS credentials in the Cert Store or still using the KYR file specified in the Internet site?

The TLS Cache takes care of finding TLS Credentials. The lookup can be either by DNS name, which is the new preferred way to specify them. So you replace the kyr file name with the DNS name.
The new cache also understands KYR file names and uses them as a tag for lookup. 

But then the TLS credentials document needs to have the kyr-file name set (which is optional in the TLS Credentials document and intended for this use case).
The right way is to always specify a DNS name. The new TLS Cache understands DNS names including wildcard certificates and supports multiple SANs.

The kyr-file entry in server doc/internet site are just used as the trigger and the first lookup. When the client supports SNI the TLS Cache will take care to find the right TLS Credentials key entry based on the SANs (Subject Alternate Names) in the certificates.

To enable logging use the following setting:

```
set config CERTSTORE_CACHELOG=1
```

This is not a CertStore but TLS Cache log parameter. The parameter is dynamic and you should always set it via "set config".

```
TLSCache-Log-http: CacheLookupRequest -> Host/Tag: [*.nashcom.de] RSAHashAlgs: 0x0, ECDSAHashAlgs: 0x0, Key: 1, Cert: 1, OCSP: 1 TrustPolicy: 1 DNList: 0
TLSCache-Log-http: CacheLookupResult: [*.nashcom.de] -> [ECDSA NIST P-256] Flags: 0x0, RSAHashAlgs: 0x1, ECDSAHashAlgs: 0x1, DefaultAssigned: 0 -> Err: 0x0
TLSCache-Log-http: CacheLookupRequest -> Host/Tag: [nashcom.de] RSAHashAlgs: 0x78, ECDSAHashAlgs: 0x78, Key: 1, Cert: 1, OCSP: 1 TrustPolicy: 1 DNList: 0
TLSCache-Log-http: CacheLookupResult: [nashcom.de] -> [ECDSA NIST P-256] Flags: 0x0, RSAHashAlgs: 0x78, ECDSAHashAlgs: 0x78, DefaultAssigned: 0 -> Err: 0x0
```

In addition with Domino 12.0.1 and higher there is a new CertMgr command to show the TLS Credentials your server uses.

```
tell certmgr show certs
```

This should give you a good understanding of the certificates used by your server.

**Note:** certmgr might not run on your server. The servertask is only required on one server in the domain and takes care of all certificate operations.
CertMgr on additional servers run in client mode and would only replicate the database and pull the replica from CertMgr server if not present.

In this case you can show the current information loaded into the cache via:


```
load certmgr -showcache
```

The result should look like the following

```
Subject key identifier    Key info     Expiration   KeyFile/Tag            Host names (SANs)
------------------------------------------------------------------------------------------------------------------------------------------------------
30D8 7A17 9BA0 CA6E ...   RSA 4096      59,0 days   keyfile.kyr            *.nashcom.de nashcom.de
07BB 3F58 13D7 4322 ...   NIST P-256    52,6 days   nashcom.de.ecdsa       *.nashcom.de nashcom.de
C71F CF82 4508 E456 ...   RSA 4096      53,0 days   rsa_domino_lab_net     *.domino-lab.net
32BA 66E5 CC03 1E00 ...   NIST P-256    69,0 days   wild-csi-ecdsa         *.csi-domino.com
CD47 55CF 76C3 E3CF ...   RSA 4096      88,9 days   wild-csi-rsa           *.csi-domino.com
19BB B3AA 5D90 7A6C ...   NIST P-256    60,7 days                          jupiter.csi-domino.com
```


# Do Internet sites which had the KYR file specified no longer need to do so?

The recommended way to specify TLS Credentials is to use a DNS name instead of the KYR file name.
However the KYR file name can be still used as a "tag" and can be used for a 1:1 assignment like in previous releases.
The recommended way is to specify a DNS name instead.


If I try to import a PEM file it complains that "Cannot import without a private key". I have the private key, but how do you specify the key to use?

The PEM, PKCS12 (p12/pfx) formats allow to include the private key. The private key must be part of the imported file.

The import is a client side operation. This means the key, cert and chain is checked on the client and stored encrypted in the TLS Credentials document.
After the key has been encrypted, the private key cannot be read by the client any more. 

The key is encrypted for the CertMgr server and all servers specified in "Servers with access:" in the moment of this import operation.

If the private key is protected with a password in the import file (PEM or PCKS12) you must specify the password.

When importing a KYR file, it asks for the current password, but it doesn't validate that password when storing the credentials.

Kyr-file imports use the password from the corresponding .sth file. The password specified in the dialog is only used for PEM and PKCS12.


# Why do I get the error "The encrypted data has been modified or the wrong key was used to decrypt it"

Please refer to the following technote for  possible reasons.

[CertMgr error: The encrypted data has been modified or the wrong key was used to decrypt it](https://support.hcltechsw.com/csm?id=kb_article&sysparm_article=KB0105749)

One well known reason is that you modified the `Servers with access:` after an import operation.
**Create exportable keys** and **importing keys and certificates** are client side operations which can't re-encrypt the key once stored.

In contrast all server side flows can re-encrypt the private key on CertMgr server.


Note: There is a known defect in the Notes 14.0 client which will be fixed in 14.0 FP1.
TLS Credentials import operations and also creating exportable keys are affected.

To import TLS Credentials please use a 12.0.1/12.0.2 client until 14.0 FP1 ships.


# Do I need to restart my Internet tasks when a TLS Credentials document changes

Once certstore.nsf is in place all internet tasks (HTTP, SMTP, POP3, IMAP, LDAP) and also other applications based on the Domino stack use the new TLS Cache automatically.
Because the TLS cache is initialized at startup of the process, you have to start it once after the database is created/replicated to the server.

From then on the TLS Cache is immediately updated on the fly as soon a change is made to a relevant TLS Credentials document for a server.
A dedicated thread on each process takes care of managing the cache. The cache reload is highly optimized and ensures the cache is always available.


# How can I migrate all my KYR files to TLS Credentials documents.

Cert manage has a command to import a single kyr file and also all configured kyr files on a server.
Each kyr file will only imported once.

As soon the TLS credentials are created, the existing *.kyr files and *.sth files should be removed from the server to avoid old kyr files would be used, if the new TLS Cache can't find a matching key.
