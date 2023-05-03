# Application Gateway Governance

In order to quickly assess your Applicaiton Gateway infastructure, you can use Resource Graph to export out the data into a CSV file and then use my AppGatewayResourceGraphParser script to report out the various configurations of the App Gateway. 

There are a few processes described on this page:

1. [Analyze settings of all Application Gateways in your environment](https://github.com/JayWitt/AzureOperationGuide/blob/master/AppGateway/Governance.md#Analyze-settings-of-all-Application-Gateways-in-your-environment)
2. [Analyze the size of the subnets that house your Applicaation Gateways](https://github.com/JayWitt/AzureOperationGuide/blob/master/AppGateway/Governance.md#Analyze-the-size-of-the-subnets-that-house-your-Application-Gateways)



## Analyze settings of all Application Gateways in your environment

NOTE: This script only reports on a subset of the total number of configurable items in an Application Gateway. It is means to be an example that can then be used to pull the rest of the items that one might be interested in collecting.

### How to use
1. Use Azure Resource Graph to run the following query
```kusto
resources
| where type == "microsoft.network/applicationgateways"
```
2. Download the results into a CSV file.

![Download As CSV](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/DownloadAsCSV.png)

3. Edit the CSV file that is downloaded and delete the following line
```CSV
SEP=,
```

4. Download the [AppGWResourceGraphParser.ps1](https://github.com/JayWitt/AzureOperationGuide/blob/master/AppGateway/AppGWResourceGraphParser.ps1) script.

5. Modify the $ResourceGraphOutputPath with the path of the location where you downloaded the CSV file from in step 2.
```Powershell
$ResourceGraphOutputPath = "<inputfilepath>"
```

6. Modify the $outputPath variable with the path and filename of where you want the output CSV file to be written.
```Powershell
$outputPath = "<outpufilepath>"
```

7. Run the Powershell script. After it is done, it will automatically open up the CSV file with your default application for CSV files.

### What is included in the output

The following settings are included in the output of the script:

* **GWName**: The name of the application gateway. 
* **ResourceGroup**: The resource group in which the application gateway resides.
* **SubscriptionID**: The subscription in which the application gateway resides.
* **ProvisionState**: The status of the build of the application gateway.
* **OperationalState**: The operating status of the applicaiton gateway.
* **SKU**: The SKU of the application gateway.
* **Tier**: The tier of the application gateway.
* **Capacity**: This value would represent the number of instances of a cluster set to manual scalling. This value will be blank if it is set to autoscale.
* **FrontEndIp**: The front end IP address of the gateway. For public IP addresses, this field will contain the resource ID of the public IP address resource. Otherwise, it is the private IP address.
* **ListenerName**: The name of one of the listeners on the application gateway.
* **RuleName**: The name of one of the rules on the application gateway.
* **PathTargetName**: If the rule is path based, this will be the name of the path map. For other rule types, this field will be blank.
* **Path**: If the rule is path based, this will contain the path of the rule.
* **PathBackendName**: If the rule is path based, this will contain the backend pool name associated to the specified path.
* **PathHttpSettingsName**: If the rule is path based, this will contain the HTTP Setting name associated to the specified path.
* **HTTPSettingName**: This will contain the HTTP Setting name associated to the specified rule.
* **Protocol**: The protocol used by the HTTP Setting.
* **HTTPProvisioningStatus**: The status of the building of the HTTP setting.
* **RedirectType**: If the rule is redirect based, this will contain the type of redirect used (Permanent, Found, or Temporary).
* **BackendPoolName**: The name of the backend pool associated to the rule.
* **BackendPoolAddresses**: The addresses that make up the backend pool.
* **Probe**: The name of the probe associated to the HTTP Setting.
* **ProbeHostName**: The name of the host of the probe.
* **ProbePath**: The path used by the probe.
* **ProbeMatch**: The match rules used by the portal.


### Beta Version
This is still a work in progress so please share any feedback and suggestions on the use of the script.

## Analyze the size of the subnets that house your Application Gateways

This isn't really a script but rather a Resource Graph query that you can then export out into a CSV to then be analyzed with Excel. This section describes the process in more detail.

For more sizing information on subnets used by Application Gateways, please look [here](https://docs.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure#size-of-the-subnet)

1. Navigate the Resource Explorer and run the query outlined [here](https://github.com/JayWitt/AzureOperationGuide/blob/master/ResourceGraph/UsefulQueries.md#Query-to-evaluate-the-number-of-IP-addresses-needed-for-App-Gateways-against-the-number-of-IPs-assigned-within-the-VNet).
2. Export the results into a CSV.

![Download As CSV](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/DownloadAsCSV.png)

3. Open the CSV file with Excel.

4. Highlight the first row and click Sort & Filter > Filter.

![Duplicate Values](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/ExcelFilter.png)

5. Highlight column H and click Conditional Formatting > Highlight Cells Rules > Duplicate Values.

![Duplicate Values](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/ConditionalFormatting.png)

6. Click Ok at the next screen.

![Duplicate Values](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/DuplicateValues.png)

7. Click the SUBNETID column filter and Sort by Color > then choose the pink color.

![Duplicate Values](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/ExcelSort.png)

8. Review the SUBNETIPCOUNT column against the number of MAXIPSNEEDED column to confirm that you will have enough IP addresses in the subnet in the event of the App Gateway scaling to its maximum.

As an example, the following two rows represent two App Gateways that are in the same subnet. Since the subnet has a CIDR range of 10.0.0.0/27, this means that there is 27 IP addresses available in that subnet to be used (32 total addresses for /27 minus 5 for Azure). Ths SUBNETIPCOUNT column already has done the calculation for you. The maximum number of IPs that the gateways in that subnet could use would be 20 (10+10). This means that the subnet has enough IP addresses if both Application Gateways were to scale out to their maximum instance counts.

![Duplicate Values](https://github.com/JayWitt/AzureOperationGuide/raw/master/AppGateway/ReadReport.png)


