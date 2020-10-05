# Useful Resource Graph Queries

The following table contains useful Resource Graph Queries:

## Show all virtual machines ordered by name in descending order
```kusto 
project name, location, type 
| where type =~ 'Microsoft.Compute/virtualMachines' 
| order by name desc
| Count virtual machines by OS Type (Windows or Linux)
| where type =~ 'Microsoft.Compute/virtualMachines' 
| summarize count() by tostring(properties.storageProfile.osDisk.osType) 
```
## List virtual machines that match something in their name (Example is for SQL)
```kusto 
where type =~ 'microsoft.compute/virtualmachines' and name contains "sql" 
| project name 
| order by name asc
```
## List virtual machines that used a 2012 version of the marketplace image (By SKU)
```kusto 
where type =~ 'microsoft.compute/virtualmachines' and tostring(properties.storageProfile.imageReference.sku)contains "2012"
| project name, tostring(properties.storageProfile.imageReference.sku)
| order by name asc 
```
## List virtual machines that used a SQL based marketplace image (By Offer)
```kusto 
where type =~ 'microsoft.compute/virtualmachines' and tostring(properties.storageProfile.imageReference.offer) contains "sql"
| project name, tostring(properties.storageProfile.imageReference.offer)
| order by name asc 
```
## List storage account count by subscription and location
```Kusto
where type =~ 'Microsoft.Storage/storageaccounts'
| summarize count() by tostring(subscriptionId), tostring(properties.primaryLocation)
```
## List all virtual machines in a certain region
```Kusto
project name, location, type 
| where type =~ 'Microsoft.Compute/virtualMachines' and location == 'eastus2'
```
## List all virtual machines with a certain VALUE in a TAG
```Kusto
project name, location, type 
| where type =~ 'Microsoft.Compute/virtualMachines' and tags.TAG contains 'VALUE'
```
## List all virtual machines with a certain VALUE in a TAG
```Kusto
project name,properties.hardwareProfile.vmSize, location, type, tags 
| where type =~ 'Microsoft.Compute/virtualMachines' and tags.Role contains 'DB'
List all virtual machines with a certain VALUE in a TAG
 where type =~ 'Microsoft.Compute/virtualMachines'
| project name, location, tags.AppName, resourceGroup
| where tags_AppName == 'CITRIX'
```
## List all virtual machines that have been registered with the SQL Virtual Machine Resource Provider and list the license type, the type of agent that is installed onto the VM, the image type along with the version of SQL
```Kusto
where type == "microsoft.sqlvirtualmachine/sqlvirtualmachines" 
| project name, properties.sqlServerLicenseType, properties.sqlManagement, properties.sqlImageOffer, properties.sqlImageSku
```
## List VMs that are using unmanaged disks
```Kusto
where properties.storageProfile.osDisk.vhd.uri <> ""
| where type =~ 'Microsoft.Compute/virtualMachines' 
| project name, tags, resourceGroup
```
## List all VMs that report to a Log Analytics Workspace
```Kusto
Resources
| where type == "microsoft.compute/virtualmachines/extensions" and name == "MicrosoftMonitoringAgent"
| extend VM1 = split(id,"/")
| extend VMName = VM1[8]
| extend LogAnalyticsWorkspaceID = properties.settings.workspaceId
| extend ProvisionState = properties.provisioningState
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project SubName, VMName, ProvisionState, LogAnalyticsWorkspaceID
```
## List the network cards that have a specific Private IP Address
**Note: Substitute the x.x.x.x with the IP address you are looking for**
```Kusto
resources
 | where type == "microsoft.network/networkinterfaces" 
 | where properties.ipConfigurations[0].properties.privateIPAddress == "x.x.x.x"
```
## List the network cards that have a specific Public IP Address
**Note: Substitute the x.x.x.x with the IP address you are looking for**
```Kusto
resources
 | where type == "microsoft.network/networkinterfaces" 
 | where properties.ipConfigurations[0].properties.publicIPAddress == "x.x.x.x"
```
## Look for the service that is using a public IP address
**Note: Substitute the x.x.x.x with the IP address you are looking for**
```Kusto
((resources
| where type == "microsoft.web/sites"
 | mvexpand ipaddr=split(properties.possibleInboundIpAddresses,",")
 | project name, type, ipaddr, resourceGroup)
| union
(resources
| where type == "microsoft.web/sites"
 | mvexpand ipaddr=split(properties.possibleOutboundIpAddresses,",")
 | project name, type, ipaddr, resourceGroup),
 (resources
| where type == "microsoft.network/publicipaddresses"
| extend  ipaddr=properties.ipAddress
| extend obj1 = split(properties.ipConfiguration.id,"/")
| extend ResourceName = obj1[8]
| extend ResourceType = obj1[6]
| project name, type, ipaddr, resourceGroup))
| where ipaddr=="x.x.x.x"
```
## List storage accounts with Firewall options enabled
```Kusto
where type == "microsoft.storage/storageaccounts" and properties.networkAcls.virtualNetworkRules <> '[]' and properties.networkAcls.ipRules <> '[]'
| project name, properties.networkAcls.virtualNetworkRules, properties.networkAcls.ipRules
```
## List all virtual machines that have been registered with the SQL Resource Provider along with the size of the VM
```Kusto
Resources
| where type == 'microsoft.sqlvirtualmachine/sqlvirtualmachines'
| extend VMName = tolower(name)
| project VMName, properties.sqlServerLicenseType, properties.sqlManagement, properties.sqlImageOffer, properties.sqlImageSku
| join kind=leftouter (Resources | where type == 'microsoft.compute/virtualmachines' | extend VMName = tolower(name) | project VMName,properties.hardwareProfile.vmSize) on VMName
```
## List of Failed SQLIaaSExtensions
```Kusto
where type == "microsoft.compute/virtualmachines/extensions"
| where name contains "sql"
| extend VM1 = split(id,"/")
| extend VMName = VM1[8]
| extend status = properties.provisioningState
| where status == "Failed"
| project VMName, name, status
```
## Search if a subnet is empty of NICs
**Note: Substitute the <subscriptionID> with the subscription ID that you wish to search**
```Kusto
where type == "microsoft.network/networkinterfaces"
| mvexpand properties.ipConfigurations 
| where properties_ipConfigurations.properties.subnet.id == "/subscriptions/<subscriptionID>/resourceGroups/StorageAccountTest/providers/Microsoft.Network/virtualNetworks/StorageAccountTest-vnet/subnets/Servers"
| project name, id
```
## Search if a NSG is used someplace
**Note: Substitute the <subscriptionID> with the subscription ID that you wish to search**
```Kusto
(resources
| where type == "microsoft.network/networkinterfaces"
| where properties.networkSecurityGroup.id == "/subscriptions/<subscriptionID>/resourceGroups/AppGateway/providers/Microsoft.Network/networkSecurityGroups/basicNsgWebHost-2-nic"
| project name, id)
| union
(resources | where type == "microsoft.network/virtualnetworks"
| mvexpand properties.subnets
| where properties_subnets.properties.networkSecurityGroup.id == "/subscriptions/<subscriptionID>/resourceGroups/AppGateway/providers/Microsoft.Network/networkSecurityGroups/basicNsgWebHost-2-nic"
| project name, id)
```
## Search for all NSGs that have a rule that involves a destination port of 3389
```Kusto
where type == "microsoft.network/networksecuritygroups"
| mv-expand rule=properties.securityRules
| where rule.properties.destinationPortRange == 3389
|project name, id, resourceGroup, rule.name, rule.properties.destinationPortRange
```