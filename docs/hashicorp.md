---
layout: default
title: "Example Integration CertMgr with HashiCorp"
nav_order: 3
parent: "Integrations"
description: "Lotus Script example to integrate CertMgr with HashiCorp as a CA"
has_children: false
---

# Example Integration CertMgr with HashiCorp

The following example shows how an external CA could be integrated leveraging the manual flow on Domino side.
In this integration uses HashiCorp as an example integration. But similar flows would work with other CAs as well.
This example shows the principle how an integration could look like

It is leveraging the manual flow. The integration hooks in when the CSR is already created.
The CSR itself could be also be created automatically, by

1. Creating the document
2. Setting the fields for manual flow
3. Save the document with `doc.status="O"` to submit it
4. Wait until CertMgr processed the request.

The current example uses the already created CSR.
The example script is started from the open TLS Credentials document with the CSR already present.

1. Send CSR to HashiCorp
2. Get back the certificate
3. Submit the TLS Credentials document to let it be processed by CertMgr to merge the certificates.

## Note: All integration flows for ACME, Manual and Import perform the following steps automatically:

1. Sort and filter certificate chains
2. Auto complete the certificate chain with root or intermediate CA certs from Trusted Roots.

This means when the root is not part of the certificates returned, it is auto complected with certificates stored as Trusted Root `certstore.nsf`.


## Main function sending a CSR request to HashiCorp and get back a certificate

- Main function to send the CSR to HashiCorp and return the certificate
- Gets the CSR from document
- Uses the Lotus Script HTTP function to talk to HashiCorp over HTTPS using their API
- Stores certificates in PEM in TLS Credentials document
- Invokes a final server side operation to merge certificates and set status

### Notes

The following is for educational purposes only and just shows the general path how to integrate.
The functionality stores the the credentials in notes.ini.
It is using the main access token. For a production style integration OIDC or other types of authentication should be used to create a vault token with a short lifetime.


```
Function HashiCorpReqeust (URL As String, Token As String, doc As NotesDocument) As String

    Dim Session As New NotesSession
    Dim data As NotesJSONNavigator
    Dim jsonNav As NotesJSONNavigator
    Dim e As NotesJSONElement
    Dim a As NotesJSONArray
    Dim ePEM As NotesJSONElement
    Dim ret As Variant
    Dim webRequest As NotesHTTPRequest
    Dim CertPEM As String
    Dim ChainPEM As String
    Dim bUseFullChain As Boolean

    Set webRequest = session.createhttprequest()
    webRequest.maxredirects= 5
    webRequest.PreferJSONNavigator = True

    Call webRequest.Setheaderfield ("X-Vault-Token", Token)
    Call webRequest.Setheaderfield ("Accept", "application/json")

    Set data = session.CreateJSONNavigator ("")
    Call data.AppendElement (doc.CSR(0), "csr")
    Call data.AppendElement ("240h", "ttl")

    Set JsonNav = webrequest.Post (URL, data.Stringify)

    If (JsonNav Is Nothing) Then
        HashiCorpReqeust = "No JSON returned"
        Exit Function
    End If

    Set e = JsonNav.GetElementByPointer ("/data/certificate")

    If (e Is Nothing) Then
        HashiCorpReqeust = "No Certificate returned"
        Exit Function
    End If

    ' Read the certificate chain
    If (bUseFullChain) Then
        Set e = JsonNav.GetElementByPointer ("/data/ca_chain")
        If Not (e Is Nothing) Then
            If e.Type = 2 Then
                Set a = e.Value
                Set ePEM = a.GetFirstElement()

                While Not (ePEM Is Nothing)
                    chainPEM = chainPEM & ePEM.Value & Chr(10)
                    Set ePEM = a.GetNextElement
                Wend

            Else
                Print "Unexpected JSON type for ca_chain: " & e.Type
            End If
        End If

    ' Use only intermediate certificate
    Else
        CertPEM = e.Value
        Set e = JsonNav.GetElementByPointer ("/data/issuing_ca")

        If (Not e Is Nothing) Then
            ChainPEM = e.Value
        End If

    End If

    doc.PastedPem = CertPEM + ChainPEM

End Function
```

## Function to search for requests and process them

- Searches for documents in the right status
- Invokes `HashiCorpReqeust()` to process the request


```
Sub HashiCorpCertRequest (Url As String, Token As String)

    Dim session As New NotesSession
    Dim db As NotesDatabase
    Dim workspace As New NotesUIWorkspace
    Dim uidoc As NotesUIDocument
    Dim doc As NotesDocument
    Dim CertStr As String
    Dim ErrorText As String

    Dim nid As String
    Dim ReqNoteUNID As String
    Dim count As Integer

    Set db = session.CurrentDatabase
    Set uidoc = workspace.CurrentDocument

    If (uidoc Is Nothing) Then
        Messagebox "Please submit request from TLS Credentials document!",48, "CertMgr"
        Exit Sub
    End If

    Set doc = uidoc.Document

    If ("" = doc.CSR(0)) Then
        Messagebox "Please submit manual request first to create a CSR!",48, "CertMgr"
        Exit Sub
    End If

    uidoc.Editmode = True

    ErrorText = HashiCorpReqeust (URL, Token, doc)

    If (ErrorText <> "") Then
        Messagebox "ERROR: " + ErrorText
        Exit Sub
    End If

    'Set submitted status to import certificate, intermediates and auto complete root
    doc.Status = "O"

    Call doc.save(True, False)
    ReqNoteUNID = doc.Universalid

    doc.SaveOptions = "0"
    Call uidoc.Reload()
    Call uidoc.Close(True)

End Sub
```

## Main function to get URL and Token

```
Sub Initialize

    Dim session As New NotesSession
    Dim Token As String
    Dim EndPoint As String

    EndPoint = session.GetEnvironmentString ("HashiCorp_PKI_URL")
    Token = session.GetEnvironmentString ("HashiCorp_PKI_Token")

    If ("" = EndPoint) Then
        EndPoint = Inputbox ("Specifiy HashiCorp PKI Endpoint URL")
        Call session.SetEnvironmentVar ("HashiCorp_PKI_URL", EndPoint)
    End If

    If ("" = Token) Then
        Token = Inputbox ("Specifiy HashiCorp PKI Token")
        Call session.SetEnvironmentVar ("HashiCorp_PKI_Token", Token)
    End If

    Call HashiCorpCertRequest (EndPoint, Token)

End Sub
```

