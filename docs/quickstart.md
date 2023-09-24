---
layout: default
title: "Quickstart"
nav_order: 2
description: "CertMgr Quickstart"
has_children: false
---

CertMgr is available since Domino 12.0. Domino 12.0.2 is the recommended Domino release. To get started with CertMgr perform the following steps:

# Select a server to be the CertMgr server and start certmgr servertask

"certstore.nsf" is designed as a domain wide database with one CertMgr server managing all web server certificates. The concept is similar to AdminP taking care of Domain wide requests. 

Usually it is a good practice to select the Domain admin server as the CertMgr server.

Starting the **certmgr** server task for the first time, creates "**certstore.nsf**" and adds the CertMgr server to the directory profile to propagate designated CertMgr server in the Domino domain.

```
Load certmgr
```

# Deploying certstore.nsf to servers in the domain

Once the CertMgr server is populated in the domain via replicating the Domino directory (names.nsf), starting the **certmgr** server task on each additional server will pull a replica of **cerstore.nsf**.

In case you have special replication considerations e.g. for custom network topology, create a **cerstore.nsf** replica manually.

The **certmgr* server task is optional on additional operates in client mode to 

- Create the *certstore.nsf* replica
- Replicate very 2 minutes independent from any replication documents (still requires to resolve the designated CertMgr server).


# Restart internet server tasks once to take benefit of CertMgr

Each server task checks on start-up if the **certstore.nsf** is available.
Therfore each server task needs to be started once after **certstore.nsf** has been created on a server.

The TLS Cache, which is part of every internet server task takes care of dynamically loading TLS Credentials automatically without any restart. 


# Import existing KYR files

certmgr can import existing KYR files referenced in server document and "internet sites".

**Note:** The old KYR Cache and the new TLS Cache operate in parallel.
Once the TLS Credentials are successfully imported, backup and remove the existing ***.kyr** and ***.sth** files.


# Create new TLS Credentials for a server

- Create a new TLS Credentials document and specify the DNS names of your your server (SANS = subject alternate names).
- Select all servers which should have access to the private key of the TLS Credentials document
- Choose the desired key format (recommended: ECDSA NIST-P 256)
- Select the right certificate flow for your environment and submit the request

CertMgr offers the following requests. Refer to the corresponding howto document below

- Manual Flow
- Micro CA
- Let's Encrypt / ACME Flow

In addition you can import existing keys and certificates

# Propaging the new TLS Credentials

Once the TLS Credentials document is updated (and replicated to the desired server), all internet tasks dynamically load the new TLS credentials document.

To check if the TLS Credential document is active start the following command

```
Load certmgr -showcerts
```

Note: CertMgr is only available on Windows/Linux and AIX since Domino 12.0.2. OS400 cannot run the CertMgr and can only consume RSA keys.
