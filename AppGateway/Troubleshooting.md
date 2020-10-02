# Azure Application Gateway Troubleshooting Guide

## Overview

The Application Gateway has many different components that are referenced in the graphic below. The graphic is meant to show how each of the items work together to make the Application Gateway v2 service work.

![App Gateway Explained](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/AppGWExplained.png)


## Common Problems:

* Root Certificate doesn’t match
   * How to detect the cert being used on the back end and if it is fully there.
* Rewrite Rule doesn’t work
   * Note that if the value in the rewrite rule doesn’t return anything then the whole header is excluded. This means that if you add a header that has “newHeader” = “{var_host}” and the host variable doesn’t have any value it in, newHeader will not even be shown in the results.
* Path Based Rules don’t work
   * You may have to enter in multiple path based rules to cover scenarios where a folder is used as the URL verses an exact filename. Example: Two path based rules would need to be setup for /site1/app1/* and /site1/app1 in order to facilitate the routing of www.host.com/site1/app1 and www.host.com/site1/app1/login.asp as the resolution engine is specific.
* WAF issues:
   * How to identify that there is a problem
   * How to build a successful Exception list entry
* How to upload the Root Certificate and Front End Certificate properly


## Certificate Requirements
It has been found that some applications that sit behind an Application Gateway respond differently in terms of how they leverage their certificates. The following notes are what has been observed when working with self-signed certificates (including those that are corporate Certificate Authorities).

The key will be to leverage the full certificate chain on the instance that is in the Backend Pool. One way to do that is to validate it by running the following command on a Linux based machine (or within the Windows Subsystem Ubuntu shell) and replace the <url> with the URL of the web site that is being front ended. NOTE: Using the Windows version of openssl doesn’t provide the same level of output.

```bash
openssl s_client -showcerts -connect <url>:443
```

The output of the command should have the following parts:

![Cert Output](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/AppGwCertExample.png)

### NGINX

For servers that are running NGINX, the certificate must be in a base64 format and include the full certificate chain. The following windows command can be used to combine the individual certs into a full certificate in the correct order.

```powershell
copy /b "server.cer"+"intermediate.cer"+"root.cer" full.cer
```
### .Net Core / Kestrel

You cannot just use the PFX file that contains the whole chain. ***Need to Analyze more***

## Troubleshooting with the logs

Make sure that the diagnostic logs are setup to go to a Log Analytics workspace for easier searching. 

### Rewrite Rules:
The key log for Rewrite Rule issues is ApplicationGatewayAccessLog. Use the following query to look in the logs from the past 10 minutes and confirm if the rewrite rules are working correctly:

```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and OperationName == "ApplicationGatewayAccess"
| where TimeGenerated >= ago(10m)
| project TimeGenerated, originalHost_s, host_s, serverRouted_s, serverStatus_s, userAgent_s, requestUri_s, originalRequestUriWithArgs_s, backendPoolName_s, backendSettingName_s, ruleName_s, listenerName_s
| order by TimeGenerated
```

### WAF Rules causing problems:
One can use the following query to help review the logs for WAF specific rules. More information can be found here: [Troubleshoot - Azure Web Application Firewall | Microsoft Docs](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/web-application-firewall-troubleshoot)

```kusto
AzureDiagnostics 
| where Category  == "ApplicationGatewayFirewallLog"
| project requestUri_s, Message, clientIP_s, ruleSetType_s, ruleSetVersion_s, ruleId_s, ruleName_s, action_s, details_message_s, hostname_s
```
Take note of those entries that have an action_s value of either Matched or Blocked as the one that show blocked and the ones right before it are probably what is causing the call to be blocked. You can either look at the data within the details_message_s value to understand what might be able to get added to the Exclusion list within the WAF or can also look at the ruleId_s value to then disable the whole rule through the steps outlined here [Troubleshoot - Azure Web Application Firewall | Microsoft Docs](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/web-application-firewall-troubleshoot#disabling-rules). ***MORE around Exception Diagnosis and remediation***

## Helpful Scripts:
For each of these scripts there will be variables that need to be set with the values that are described within the brackets near the top of each of the scripts.

### Get Frontend Certificate details
Use this script to list out the certificates that can be used by the listeners. It does include the whole chain for each cert. 

```azurepowershell
$appGWName = "Application Gateway Name"
$appGWRG = "<Application Gateway Resource Group Name"

$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG

$ListenerCert = Get-AzApplicationGatewaySslCertificate -ApplicationGateway $AppGW

Add-Type -AssemblyName System.Security

foreach ($Listener in $ListenerCert)
{
    write-host "Certificate Name: $($Listener.Name)"  
    $ListenerCertData = [System.Convert]::FromBase64String($Listener.PublicCertData)
    $p7b = New-Object System.Security.Cryptography.Pkcs.SignedCms
    $p7b.Decode($ListenerCertData)
    $p7b.Certificates |ft

} 
```
Sample Output:

![Sample Output](https://github.com/JayWitt/AzureOperationGuide/raw/main/AppGateway/SampleOutput.png)

### Remove Trusted Root Certificate
Use this script to remove a trusted root certificate from the App Gateway.
```azurepowershell
$appGWName = "Application Gateway Name"
$appGWRG = "<Application Gateway Resource Group Name"
$certName = “<Name of Root Certificate>”

$gw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG
$gw = Remove-AzApplicationGatewayTrustedRootCertificate -ApplicationGateway $gw -Name $certName
$gw = Set-AzApplicationGateway -ApplicationGateway $gw 
```

### Listed Trusted Root Certificates
Use this script to view the Trusted Root Certificate options that have already been loaded into the gateway.

```azurepowershell
$appGWName = "Application Gateway Name"
$appGWRG = "<Application Gateway Resource Group Name"

$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG
$root = Get-AzApplicationGatewayTrustedRootCertificate -ApplicationGateway $AppGW

foreach ($rootCert in $root){
    write-host "Root Certificate Name: $($rootCert.Name)"
    $rootCertData = $rootCert.data
    $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]([System.Convert]::FromBase64String($rootCertData))
    $cert | fl
} 
```

### Stop Application Gateway
Use this script to stop an App Gateway. <span style="color: red;">**NOTE: If the IP address is not static, you may lose the IP.**</span>

```azurepowershell
$appGWName = "Application Gateway Name"
$appGWRG = "<Application Gateway Resource Group Name"

$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG

Stop-AzApplicationGateway -ApplicationGateway $AppGw
```

### Start Applicaiton Gateway
Use this script to start an Application Gateway. NOTE: You do not need to rerun the first 3 lines of this script if you had already set them in the Stop Application Gateway script above.

```azurepowershell
$appGWName = "Application Gateway Name"
$appGWRG = "<Application Gateway Resource Group Name"

$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG

Start-AzApplicationGateway -ApplicationGateway $AppGw 
```

### Add a new SSL Certificate
This script can be used to add in a new SSL certificate that can then be used to be added to the listener.
```azurepowershell
$appGWName = "<Application Gateway Name>"
$appGWRG = "<Application Gateway Resource Group Name>"
$certName = "<Certification Name>"
$certPath = "<Certificate Path>"

$certPassword = Read-Host "Enter Password for PFX" -AsSecureString
$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG
Add-AzApplicationGatewaySslCertificate -ApplicationGateway $AppGw -Name $certname -CertificateFile $certPath -Password $certPassword
Set-AzApplicationGateway -ApplicationGateway $Appgw 
```

### Remove a SSL Certificate (Frontend)
This script can be used to delete a SSL certificate. Please note that the SSL certificate cannot be used by a listener. If the certificate is causing a problem, you can remove it and re-add it with the same name by merging the Add and Remove commands from the previous script example.

```azurepowershell
$appGWName = "<Application Gateway Name>"
$appGWRG = "<Application Gateway Resource Group Name>"
$certName = "<Certification Name>"

$certPassword = Read-Host "Enter Password for PFX" -AsSecureString
$AppGw = Get-AzApplicationGateway -Name $appGWName -ResourceGroupName $appGWRG
Remove-AzApplicationGatewaySslCertificate -Name $certname -ApplicationGateway $AppGW
Set-AzApplicationGateway -ApplicationGateway $Appgw 
```
