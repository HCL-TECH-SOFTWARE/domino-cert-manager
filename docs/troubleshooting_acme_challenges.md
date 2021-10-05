# Troubleshooting ACME HTTP-01 challenges

## Verify requirements

### Inbound port 80

ACME HTTP-01 challenges used by CertMgr to confirm Let's Encrypt challenge requests require an inbound HTTP connection on port 80.  
At least the first request has to be HTTP on port 80. The request can be redirected to another server and also to HTTPS if you have an existing server.  

As a first test if your server is reachable for Let's Encrypt, you can use the [Let's Debug script](https://letsdebug.net/).


### DNS name resolution for the requested hostnames / SANs

The DNS names requested for one or multiple SANs need to point to this server and any server which is configured in DNS (or behind a load-balancer) needs to be able to reply to the ACME challenge sent via the ACME protocol to Domino to host.

The CertMgr server stores the challenge information in `certstore.nsf` and other servers in the Domino domain can read the challenge data and present it.

### CertMgr DSAPI filter

Domino V12 requires the `certmgrdsapi` DSAPI filter to be enabled.  
The DSAPI filter intercepts the request for the challenge, looks up the token and presents it to the ACME server requesting the challenge information.

The DSAPI filter logs the following type of message when initialized

```
27.09.2021 12:01:00   CertMgrDSAPI: CertMgr / ACME & Let's Encrypt DSAPI
27.09.2021 12:01:00   HTTP Server: DSAPI CertMgrDSAPI Loaded successfully
```

Note: Beginning with Domino V12.0.1 the DSAPI filter functionality has been incorporated into the HTTP task and no DSAPI filter will be requrired. The functionality is enabled by default.  

### Request URLs

The well known URLs for challenge requests have the following form

```
http://www.acme.com/.well-known/acme-challenge/xzy..
```

If a load balancer or any type of security appliance is placed in front of the Domino server, make sure those type of requests are routed to the Domino HTTP server.

## Inbound connection without authentication

If the server does only allow authenticated access, define the ACME challenge URL as a public URL.

The notes.ini parameter can be used to allow additional URLs to be public and do not need authentication.  
You can specify multple entries speparated with `:`. If the URL is not complete, append a `*` to the string as shown in the below example.

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
- You can see the document in the ($AllDocuments) troubleshooting view (open database with Ctrl-Shift + Application/Goto..)

Now you can query the test DNS challenge using a web-browser or curl command-line.  
The `-L` option is important when you redirect the challenge to another server.

### Example command line

```
curl -L http://www.acme.com/.well-known/acme-challenge/DOMINO-CertMgr-DiagChallenge-HTTP01
```

Tip: If you get no result or the wrong result you might want to add the verbose mode `-v`

### Successful result

The output should look exactly like this:

```
DOMINO-ACME-PROTOCOL-CHALLANGE-DATA-OK
```

If this result is returned to a web browser or curl command, the infrastructure is ready for ACME HTTP-01 challenges.

### Next steps in case of unexpected result

In case your are getting a different reply, you have to check your whole inbound connection infrastructure. From DNS, to load-balancers and other services running on the same machine.

The curl command can help to invoke the request in different network locations in your infrastructure to find out which component might block, redirect or reply to this request instead of your Domino HTTP server.

### Common error cases

- HTTP is redirected to HTTPS and there is no TLS Credentials document yet or the mapping is wrong
- Only authenticated connections are enabled and public URL environment variable is not set
- Another application is listening on port 80
- The load-balancer or any other active filter blocks the request
- Wrong DNS entry for requested host name (either internal or external)
- IPv4 and IPv4 DNS entries but Domino is only configured for IPv4

### Querying IPv6 vs IPv4

In case you have IPv6 address DNS entries for your hostname, you have to verify that also the IPv6 address can be reply to the challenge request.  
When testing connectivity for IPv6 make sure the environment you are using to test the remote connection via curl also supports IPv6.

Curl has specify parameters to either query the IPv4 ( -4 ) or IPv6 address ( -6 )  
Make sure your Domino server can resolve those DNS names accrodingly.
Let's Encrypt will check the challenge based on the DNS entries. And also leverages multi point checks.  
So you will see requests from different servers and have to make sure the reply is always the valid challenge reply requested. 


### ACME test challenge DXL File

```
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE database SYSTEM 'xmlschemas/domino_11_0_1.dtd'>
<database xmlns='http://www.lotus.com/dxl' version='11.0' maintenanceversion='1.0'>
<document form='AcmeChallenge'>
<item name='ChallengeContent'><text>DOMINO-ACME-PROTOCOL-CHALLANGE-DATA-OK</text></item>
<item name='ChallengeName'><text>/.well-known/acme-challenge/DOMINO-CertMgr-DiagChallenge-HTTP01</text></item></document>
</database>
```

