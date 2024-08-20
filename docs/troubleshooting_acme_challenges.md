---
layout: default
title: "Troubleshooting ACME HTTP-01 Challenges"
nav_order: 1
parent: "Troubleshooting"
description: "Troubleshooting ACME HTTP-01 Challenges"
has_children: false
---

# Troubleshooting ACME HTTP-01 challenges

## Verify requirements

### Inbound port 80

ACME HTTP-01 challenges used by CertMgr to confirm Let's Encrypt challenge requests require an inbound HTTP connection on port 80.  
The challenge verification for each certificate request always starts on **HTTP on port 80**. The request can be redirected to another server. The target can be any domain, but the target port has to be either **port 80** or **port 443**. HTTPS certificates are not verified.

The first request does not need to reach the Domino server directly. You can also intercept the HTTP request on port 80 on a load balancer or reverse proxy, redirecting it to another server or the same Domino server over HTTPS.

See [implementation details](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) for the ACME HTTP-01 challenge on the Let's Encrypt website.
Also check [Best Practice - Keep Port 80 Open](https://letsencrypt.org/docs/allow-port-80/).

As a first test if your server is reachable for Let's Encrypt, you can use the [Let's Debug script](https://letsdebug.net/).  
If this test fails you might have a more general problem. If the test is successful, that doesn't mean it has to work for your.  
The script can only perform some general troubleshooting steps described on their GitHub repository. But this is a good starting point.

If it fails the following steps are still relevant for you.


### DNS name resolution for the requested hostnames / SANs

The DNS names requested for one or multiple SANs need to point to this server and any server which is configured in DNS (or behind a load-balancer) needs to be able to reply to the ACME challenge sent via the ACME protocol to Domino to host.

CertMgr server stores the challenge information in `certstore.nsf` and other servers in the Domino domain can read the challenge data and present it.


### GEO fencying protected servers mostly fail Let's Encrypt ACME HTTP-01 Challenges

Let's Encrypt validates the challenge from multiple network points around the world -- [Validating challenges from multiple network vantage points](https://community.letsencrypt.org/t/acme-v1-v2-validating-challenges-from-multiple-network-vantage-points/112253).
You usually can't assume network requests come from a well defined country. Other ACME provides might have different requirements.  
Depending on your configuration you might be lucky that sufficient number of challenges are successful.  
But in most cases HTTP-01 cannot be used. If your DNS provider supports a DNS API, you might want to consider switching to DNS-01 challenges, which don't require an inbound connection for validation.

In case challenges fail the ACME request will fail with an error returned by the ACME protocol. The error will look probably like a general network connecting error depending on the way the request is blocked.


### Domino HTTP-01 ACME Challenge integration

Beginning with Domino 12.0.1 the HTTP automatically handles ACME HTTP-01 challenge.

The functionality is automatically enabled on HTTP server start, once the cerstore.nsf database is present.

Ensure you restart the HTTP task once after cerstore.nsf is created.

The HTTP task requires are complete restart via:

```
restart task http
```

After restarting a message in the following form will be printed.
Verify of the right CertMgr server is displayed.


```
HTTP Server: ACME HTTP-01 Extension loaded - CertMgr Server: [pluto/NotesLab]
```

### Domino 12.0 only - CertMgr DSAPI filter

Beginning with Domino V12.0.1 the DSAPI filter functionality has been incorporated into the HTTP task and no DSAPI filter will be required. The functionality is enabled by default.  

Domino 12.0 requires the `certmgrdsapi` DSAPI filter to be enabled.  
The DSAPI filter intercepts the request for the challenge, looks up the token and presents it to the ACME server requesting the challenge information.

The DSAPI filter logs the following type of message when initialized

```
27.09.2021 12:01:00   CertMgrDSAPI: CertMgr / ACME & Let's Encrypt DSAPI
27.09.2021 12:01:00   HTTP Server: DSAPI CertMgrDSAPI Loaded successfully
```


### Request URLs

The well known URLs for challenge requests have the following form

```
http://www.acme.com/.well-known/acme-challenge/xzy..
```

If a load balancer or any type of security appliance is placed in front of the Domino server, make sure those type of requests are routed to the Domino HTTP server.

## Inbound connection without authentication

If the server does only allow authenticated access, define the ACME challenge URL as a public URL.

The notes.ini parameter can be used to allow additional URLs to be public and do not need authentication.  
You can specify multiple entries separated with `:`. If the URL is not complete, append a `*` to the string as shown in the below example.

Example notes.ini including redir.nsf and ACME HTTP-01 public URL definition:

```
HTTPPUBLICURLS=/redir.nsf/*:/.well-known/acme-challenge/*
```


## Testing inbound challenge requests

The functionality to query HTTP-01 challenges is implemented via DSAPI filter in Domino 12.0.
Starting with Domino 12.0.1 HTTPS natively supports HTTP-01 challenges without a DSAPI filter.  

Any server will reply to those challenge requests matching the well known acme-challenge URL schema with the secret challenge information stored in certstore.nsf.

This lookup functionality can be tested without an actual ACME request.  

### Steps to check inbound connections to the well known URL

- Create a DXL file e.g. acme_diag_challenge.dxl with the data shown below
- Import the file into certstore.nsf (`Import DXL` action in the database)
- You can see the document in the ($AllDocuments) troubleshooting view (open database with CTRL-Shift + Application/Goto..)

Now you can query the test DNS challenge using a web-browser or `curl` command-line.  

`Curl` is a well known command-line tool often used in the Linux world but also out of the box available starting with Windows 10/2019.  
You can also separately download it.

It is the de-facto standard for command-line HTTP/HTTPS requests.

Refer to the [project homepage](https://curl.se/) for details.   
You will find reference documentation and a complete [book](https://everything.curl.dev/) about Curl.  
Check the following [section](https://everything.curl.dev/cmdline) for command-line operations.

The `-L` option is important when you redirect the challenge to another server. This options follows redirects.  
In case you see no output use `-v` for more verbose output to see protocol information and headers returned.


### Example command line


In most cases a test in the following form (replacing your server name) should provide more detailed information.

```
curl -L -v http://www.acme.com/.well-known/acme-challenge/DOMINO-CertMgr-DiagChallenge-HTTP01
```

### Successful result

The output should look exactly like this:

```
DOMINO-ACME-PROTOCOL-CHALLENGE-DATA-OK
```

If this result is returned to a web browser or curl command, the infrastructure is ready for ACME HTTP-01 challenges.

### Next steps in case of unexpected result

In case your are getting a different reply, you have to check your whole inbound connection infrastructure. From DNS, to load-balancers and other services running on the same machine.

The curl command can help to invoke the request in different network locations in your infrastructure to find out which component might block, redirect or reply to this request instead of your Domino HTTP server.


### Troubleshooting internal connections problems verifying challenges

By default CertMgr verifies the HTTP-01 challenge before confirming the HTTP-01 in the ACME protocol flow.  
This functionality is important to ensure that challenges are in place before the ACME provider tried to verify the challenge.

In case your Domino server cannot resolve the hostname(s) in the certificate requested or you have no HTTP connection to your server from the CertMgr server, you can disable the verification step.

- In Domino V12.0 start the certmgr servertask with the option **-g** (e.g. load certmgr -g)
- Domino V12.0.1 introduces a new notes.ini parameter **CertMgr_NoVerifyHTTPChallenge=1** to disable the verification step.

To troubleshoot the verification step, leverage the test challenge described earlier and query it directly on operation system level via the described `curl´ command.


### Common error cases

- HTTP is redirected to HTTPS and there is no TLS Credentials document yet or the mapping is wrong
- Only authenticated connections are enabled and public URL environment variable `HTTPPUBLICURLS` is not set
- Another application is listening on port 80
- The load-balancer or any other active filter blocks the request
- Wrong DNS entry for requested host name (either internal or external)
- IPv4 and IPv6 DNS entries but Domino is only configured for IPv4

### Collecting Troubleshooting information

CertMgr can write a detailed debug log stored in `IBM_TECHNICAL_SUPPORT` directory.  
In addition all HTTP/HTTPS communication is leveraging LibCurl which allows to log all input/output on low level.  
Specifying the following debug settings allows you to further narrow down any communications or protocol issues. And provides valuable information for support.  

Note: Ensure to remove passwords and authentications tokens from the logs.

Shutdown certmgr and restart it again with the following parameters:

```
load certmgr -l -d

-d   Debug (IBM_TECHNICAL_SUPPORT/certmgr_debug_[..].log})
-l   Log curl requests to file (IBM_TECHNICAL_SUPPORT/certmgr_curl__[..].log})
```

Example files:

```
certmgr_curl_domino-lab-admin-srv_2021_10_31@08_42_00.log
certmgr_debug_domino-lab-admin-srv_2021_10_31@08_42_00.log
```

### Special note for environments using a proxy configuration

In case you are using a proxy configuration, ensure your curl command uses the same proxy configuration.

For security reasons CertMgr ignores external proxy configurations specified via environment variables and has it's own proxy configuration including authentication options. If configured in CertMgr, all HTTP requests use the same proxy configuration! For testing you have to make sure you are using the same settings for curl.

- Proxy syntax: [CURLOPT_PROXY](https://curl.se/libcurl/c/CURLOPT_PROXY.html)
- More details about curl and proxies: [Everything curl / HTTP Proxies](https://everything.curl.dev/usingcurl/proxies)


### Querying IPv6 vs IPv4

In case you have IPv6 address DNS entries for your hostname, you have to verify that also the IPv6 address can be reached in the same way.  
When testing connectivity for IPv6 make sure the environment you are using to test the remote connection via curl also supports IPv6.

Curl has specify parameters to either query the IPv4 ( -4 ) or IPv6 address ( -6 )  
Make sure your Domino server can resolve those DNS names accordingly.
Let's Encrypt will check the challenge based on all DNS entries (IPv4 and IPv6). And also leverages multi point checks.  
So you will see requests from different servers and have to make sure the reply is always the valid challenge reply requested. 


### ACME test challenge DXL File

- Create a DXL file with this content
- Use the import action in cerstore.nsf to import the DXL file
- See detailed steps earlier in this document how to query the challenge


```
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE database SYSTEM 'xmlschemas/domino_11_0_1.dtd'>
<database xmlns='http://www.lotus.com/dxl' version='11.0' maintenanceversion='1.0'>
<document form='AcmeChallenge'>
<item name='ChallengeContent'><text>DOMINO-ACME-PROTOCOL-CHALLENGE-DATA-OK</text></item>
<item name='ChallengeName'><text>/.well-known/acme-challenge/DOMINO-CertMgr-DiagChallenge-HTTP01</text></item></document>
</database>
```

### References and further information

Documentation:  
[Let's Encrypt documentation](https://letsencrypt.org/docs/)

RFC:  
[RFC 8555 Automatic Certificate Management Environment (ACME)](https://datatracker.ietf.org/doc/rfc8555/)
