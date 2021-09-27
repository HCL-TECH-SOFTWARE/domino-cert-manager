# Troubleshooting ACME challenges

## Verify requirements

### Inbound port 80

ACME HTTP-01 challenges used by CertMgr to confirm Let's Encrypt challenge request, requires an inbound HTTP connection on port 80.  
At least the first request has to be HTTP on port 80. The request can be redirected to another server and also to HTTPS if you have an existing server.  

### DNS name resolution for the requested hostnames / SANs

The DNS names requested for one or multiple SANs needs to point to this server and any server which is configured in DNS (or behind a load-balancer) needs to be able to reply to the ACME challenge sent via the ACME protocol to Domino to host.

The CertMgr server stores the challenge infomration in `certstore.nsf` and other servers in the Domino domain can read the challenge data and present it.

### CertMgr DSAPI filter

Domino V12 requires the `certmgrdsapi` DSAPI filter to be enabled.  
The DSAPI filter intercepts the request for the challenge, looks up the token and presents it to the ACME server requesting the challenge informaiton.

The DSAPI filter logs the following type of message when initialized:

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

In case a load balancer or any type of security applicance is in place in front of the Domino server, make sure those type of requests are routed to the Domino HTTP server.

## Testing inbound challenge requests

The functionality to query HTTP-01 challenges is implemented via DSAPI filter (HTTP in V12.0.1).  
Any server will reply to those challenge requests matching the well known acme-challenge URL schema with the secret challenge infomration stored in certstore.nsf.

This lookup functionality can be tested without an actual ACME request.  

### Steps to check inbound connections to the well known URL

- Create a DXL file e.g. acme_diag_challenge.dxl with the data shown below
- Import the file into certstore.nsf
- You can see the document in the ($AllDocuments) troubleshooting view (open database with Ctrl-Shift + Application/Goto..)

Now you can query the test DNS challenge using a web-browser or curl command-line.  
The `-L` option is important when you redirect the challenge to another server.

### Example command line

```
curl -L http://www.acme.com/.well-known/acme-challenge/DOMINO-CertMgr-DiagChallenge-HTTP01
```

### Successful result

The output should look exatly like this:

```
DOMINO-ACME-PROTOCOL-CHALLANGE-DATA-OK
```

If this result is returned to a web-browser or curl command, the infrastructure is ready for ACME HTTP-01 challenges.

### Next steps in case of unexpected result

In case your are getting a different reply, you have to check your whole inbound connection infrastructure. From DNS, to load-balances, other services running on the same machine etc.

The curl command can help you to invoke the quest in different network location in your infrastructure to find out which component might block, redirect or reply to this request instead of your Domino HTTP server.

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

