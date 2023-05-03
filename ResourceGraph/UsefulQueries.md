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
## List the network cards that have a specific Public IP Address (More Advanced)
**Note: Substitute the x.x.x.x with the IP address you are looking for**
```Kusto
resources
| where type == "microsoft.network/publicipaddresses"
| extend pIP = properties.ipAddress
| where pIP == "x.x.x.x"
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
## Look for private IPs of API Management instances
**Note: Substitute the x.x.x.x with the IP address you are looking for**
```Kusto
resources
| where type == "microsoft.apimanagement/service"
 | mvexpand ipaddr=split(properties.privateIPAddresses,",")
 | project name, type, ipaddr, resourceGroup
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
## Search for all NSGs that have a rule that would allow for traffic over port 5986
```Kusto
resources
| where type == "microsoft.network/networksecuritygroups"
| mv-expand rule=properties.securityRules
| where rule.properties.destinationPortRange == 5986 or rule.properties.destinationPortRange == "*"
| where rule.properties.direction == "Inbound"
| where rule.properties.access == "Allow"
|project name, id, rule, resourceGroup, rule.name, rule.properties.description, rule.properties.sourceAddressPrefix, rule.properties.sourceAddressPrefixes, rule.properties.direction,rule.properties.access, rule.properties.destinationAddressPrefix, rule.properties.destinationAddressPrefixes, rule.properties.destinationPortRange
```
## Identify managed disks that are not associated to a VM
```kusto
where type == "microsoft.compute/disks"
| where managedBy == ""
| extend SKU = sku.name
| extend disksize = properties.diskSizeGB
| extend diskstate = properties.diskState
| project name, location, resourceGroup, SKU, disksize, diskstate
```
## Identify unused NICs
```kusto
resources
 | where type == "microsoft.network/networkinterfaces" 
 | extend VM = properties.virtualMachine.id
 | extend PrivateLink = properties.privateEndpoint.id
 | where  (VM == "" and PrivateLink == "")
```
## Query Azure Monitor Alerts (Log Search based)
NOTE: This query doesn't return data on alerts that have no action groups defined.<br>
```kusto
resources
| where type == "microsoft.insights/scheduledqueryrules"
| mv-expand datasource = properties.scopes
| extend ds1 = split(datasource,"/")
| extend dsSub = ds1[2]
| extend dsRG = ds1[4]
| extend dsProv = ds1[6]
| extend dsRes = ds1[8]
| extend enabled = properties.enabled
| extend severity = properties.severity 
| mv-expand  qu1 = properties.criteria.allOf
| extend query = qu1.query
| extend metric = qu1.metricName
| mv-expand actionGroupID = properties.actions.actionGroups
| extend linkID = toupper(tostring(actionGroupID))
| join kind=leftouter (resources
| where type == "microsoft.insights/actiongroups"
| extend gName = name
| extend linkID = toupper(tostring(id))
| project gName, linkID) on linkID
| project name, subscriptionId, resourceGroup, datasource, dsSub, dsRG, dsProv, dsRes, query, severity, metric, enabled, gName, linkID
```
<sub>Last Updated: 5-10-2022</sub>

## Query Azure Monitor Alerts (Log Search based filter by Provider Type)
Add this line to the above script to be able to narrow down to Application Gateways.
```kusto
| where tostring(datasource) contains "Microsoft.Network/applicationGateways"
```

## Query Azure Monitor Alerts (Resource/Service Health and Activity Log based alerts)
NOTE: Some Action Groups may be blank, but the linkID will be populated. In this case, the Action Group has a space in it which means it won't match. I need to figure out another creative way to get these to match.
```kusto
resources
| where type == "microsoft.insights/activitylogalerts"
| extend alertnm = split(id,"/")
| extend name = alertnm[8]
| extend description = properties.description
| extend enabled = properties.enabled
| mv-expand actionGroupID = properties.actions.actionGroups
| extend linkID = toupper(tostring(actionGroupID.actionGroupId))
| extend condition = properties.condition
| join kind=leftouter (resources
| where type == "microsoft.insights/actiongroups"
| extend gName = name
| extend linkID = toupper(tostring(id))
| project gName, linkID) on linkID
| project name, resourceGroup, subscriptionId, enabled, condition, gName, linkID
```
<sub>Last Updated: 5-10-2022</sub>

## Query Azure Monitor Alerts (Resource/Service Health and Activity Log based alerts)
Add this line to the above script to be able to narrow down to Application Gateways.
```kusto
| where tostring(condition) contains "Microsoft.Network/applicationGateways"
```
## Query Azure Monitor Alerts (Metrics based)
```kusto
resources
| where type == "microsoft.insights/metricalerts"
| extend enabled = properties.enabled
| mv-expand actionGroupID = properties.actions
| extend linkID = toupper(tostring(actionGroupID.actionGroupId))
| extend criteria = properties.criteria
| extend severity = properties.severity 
| mv-expand scp1 = properties.scopes
| extend ds1 =split (scp1,"/")
| extend dsSub = ds1[2]
| extend dsRG = ds1[4]
| extend dsProv = ds1[6]
| extend dsRes = ds1[8]
| extend description = properties.description
| join kind=leftouter (resources
| where type == "microsoft.insights/actiongroups"
| extend gName = name
| extend linkID = toupper(tostring(id))
| project gName, linkID) on linkID
| project name, subscriptionId, resourceGroup, description, dsSub, dsRG, dsProv, dsRes, criteria, severity, enabled, gName, linkID
```
<sub>Last Updated: 5-10-2022</sub>

## Query Azure Monitor Alerts (Metrics based)
Add this line to the above script to be able to narrow down to Application Gateways.
```kusto
| where tostring(criteria) contains "Microsoft.Network/applicationGateways"
```
## Query Azure Monitor Alerts (Smart Detect based [Applicaiton Insights based])
```kusto
resources
| where type == "microsoft.alertsmanagement/smartdetectoralertrules"
| extend alerttype = properties.detector.name
| extend state = properties.state
| extend severity = properties.severity 
| mv-expand scp1 = properties.scopes
| extend ds1 =split (scp1,"/")
| extend dsSub = ds1[2]
| extend dsRG = ds1[4]
| extend dsProv = ds1[6]
| extend dsRes = ds1[8]
| mv-expand actionGroupID = properties.actionGroups.groupIds
| extend linkID = toupper(tostring(actionGroupID))
| join kind=leftouter (resources
| where type == "microsoft.insights/actiongroups"
| extend gName = name
| extend linkID = toupper(tostring(id))
| project gName, linkID) on linkID
| project name, subscriptionId, resourceGroup, alerttype, state, severity, gName, linkID
```
<sub>Last Updated: 5-10-2022</sub>

## Query Action Group Details
```kusto
resources
| where type == "microsoft.insights/actiongroups"
| extend RunbookReceivers = properties.automationRunbookReceivers
| extend FunctionReceivers = properties.azureFunctionReceivers
| extend AppPushReceivers = properties.azureAppPushReceivers
| extend LogicAppReceivers = properties.logicAppReceivers
| extend eventhubReceivers = properties.eventhubReceivers
| extend webhookReceivers = properties.webhookReceivers
| extend armRoleReceivers = properties.armRoleReceivers
| extend voiceReceivers = properties.voiceReceivers
| extend emailReceivers = properties.emailReceivers
| extend smsReceivers = properties.smsReceivers
| project name, id, AppPushReceivers, armRoleReceivers, emailReceivers, eventhubReceivers, FunctionReceivers, LogicAppReceivers, RunbookReceivers, smsReceivers, voiceReceivers, webhookReceivers
```
## Query AppGateway backend configurations
NOTE: This will generate one line per backend configuration (either by IP address, FQDN, or by VM)
```kusto
resources
| where type == "microsoft.network/applicationgateways"
| extend operationalState = properties.operationalState
| extend provisionState = properties.provisioningState
| extend SKU = properties.sku.name
| extend Tier = properties.sku.tier
| extend Capacity = properties.sku.capacity
| mv-expand bap = properties.backendAddressPools
| extend backendName = bap.name
| extend backendAdddresses = bap.properties.backendAddresses
| extend backendIPConfigs = bap.properties.backendIPConfigurations
| project name, resourceGroup, subscriptionId, provisionState, operationalState, SKU, Tier, Capacity, backendName, backendAdddresses,backendIPConfigs
```

## Query Resource Graph for specific types of resources within a set of Subscriptions
This is useful for responding to Service Health Alerts where the subscription names/IDs and resource types are provided and you need to list out the resources needed. In the below example, the search is looking for Azure Migrate and Azure Automation accounts.
```kusto
resources
| where type in ("microsoft.migrate/assessmentprojects","microsoft.migrate/migrateprojects","microsoft.migrate/migrateprojects","microsoft.migrate/movecollections","microsoft.migrate/projects","microsoft.automation/automationaccounts")
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions'
| project SubscriptionName=name,subscriptionId) on subscriptionId
| where subscriptionId in ("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx","xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
```

## Query to evaluate the number of IP addresses needed for App Gateways against the number of IPs assigned within the VNet
This query is best used to export the data out into an CSV for analysis in Excel where you can setup conditional formatting on the SubnetID column to identify subnets that are sharing applicaiton gateways. More information can be found [here](https://github.com/JayWitt/AzureOperationGuide/blob/master/AppGateway/Governance.md#Analyze-the-size-of-the-subnets-that-house-your-Application-Gateways) in the troubleshooting section of App Gateways.
```kusto
resources
| where type == "microsoft.network/applicationgateways"
| extend maxCapacity = iff(properties.autoscaleConfiguration.maxCapacity != "",properties.autoscaleConfiguration.maxCapacity,properties.sku.capacity)
| extend maxIPsNeeded = iff(properties.frontendIPConfigurations contains "Internal",maxCapacity+1,maxCapacity)
| mv-expand gatewayIPs = properties.gatewayIPConfigurations
| extend subnetID = tostring(gatewayIPs.properties.subnet.id)
| join kind=leftouter (resources
| where type == "microsoft.network/virtualnetworks"
| mv-expand subNetworks = properties.subnets
| extend subnetID = tostring(subNetworks.id)
| extend prefix = subNetworks.properties.addressPrefix
| extend prefixarr = split(prefix,"/")
| extend subnetIpCount = pow(2,32-prefixarr[1])-5
| project prefix, subnetID, subnetIpCount) on subnetID
| project id, name, resourceGroup, subscriptionId, maxCapacity, maxIPsNeeded, subnetIpCount, prefix, subnetID
```

## Query the list of subscriptions along with the Management Group Hierarchy
```kusto
ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| extend  mgParent = properties.managementGroupAncestorsChain
| project subscriptionId, name, mgParent
```

## Query the list of Service Health Alerts that have fired per subscription
This will list the alert name, type of alert, and the impacted service along with its tracking ID and time/dates of when the alert had fired.
```kusto
resources
| where type == "microsoft.insights/activitylogalerts"
| extend alertnm = split(id,"/")
| extend alertname = alertnm[8]
| extend alertRG = resourceGroup
| extend enabled = properties.enabled
| mv-expand actionGroupID = properties.actions.actionGroups
| extend linkID = toupper(tostring(actionGroupID.actionGroupId))
| extend condition = properties.condition
| mv-expand Impact = properties.condition.allOf
| extend Services = Impact.containsAny
| where isnotnull(Services)
| mv-expand Impacted2 = Services
| extend ImpactedService = tostring(Impacted2)
| join kind=inner (ServiceHealthResources
| where type =~ 'Microsoft.ResourceHealth/events'
| extend eventType = properties.EventType, status = properties.Status, eventdescription = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = properties.ImpactStartTime, impactMitigationTime = properties.ImpactMitigationTime
| mv-expand Impact = properties.Impact
| extend ImpactedService = tostring(Impact.ImpactedService)) on ImpactedService,subscriptionId
| project alertname, alertRG, subscriptionId, eventType, status, ImpactedService, trackingId, todatetime(impactStartTime), todatetime(impactMitigationTime), eventdescription, summary
```

## Query the list of active Service Health Alerts
```kusto
ServiceHealthResources
| where type =~ 'Microsoft.ResourceHealth/events'
| extend eventType = properties.EventType, status = properties.Status, eventdescription = properties.Title, trackingId = properties.TrackingId, summary = properties.Summary, priority = properties.Priority, impactStartTime = todatetime(properties.ImpactStartTime), impactMitigationTime = todatetime(properties.ImpactMitigationTime), SubscriptionId = properties.SubscriptionId, level = properties.Level, HIR = properties.IsHIR
| mv-expand Impact = properties.Impact
| extend ImpactedService = tostring(Impact.ImpactedService)
| where status == "Active"
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions'
| project SubscriptionName=name,subscriptionId) on subscriptionId
| where impactMitigationTime > now()
| where impactStartTime > ago(90d)
| project eventdescription, SubscriptionName, subscriptionId, trackingId, status, level, eventType, ImpactedService, todatetime(impactStartTime), todatetime(impactMitigationTime)
| order by SubscriptionName, tostring(trackingId) asc 
```

## Query which VMs are using a specific extension.
NOTE: This example looks for the VM Guest Health agent. You can change out "GuestHealth" in the below query to look for other extension names.
```kusto
Resources
| where type == 'microsoft.compute/virtualmachines'
| extend
	JoinID = toupper(id),
	OSName = tostring(properties.osProfile.computerName),
	OSType = tostring(properties.storageProfile.osDisk.osType),
	VMSize = tostring(properties.hardwareProfile.vmSize)
| join kind=leftouter(
	Resources
	| where type == 'microsoft.compute/virtualmachines/extensions'
	| extend
		VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),
		ExtensionName = name
) on $left.JoinID == $right.VMId
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| summarize Extensions = make_list(ExtensionName) by id, name, SubName, subscriptionId, OSName, OSType, VMSize
| where Extensions contains "GuestHealth"
| order by tolower(OSName) asc
```

## Query which reports the number of resources in each subscription with the number of unique tag values. (Count of tags per subscription)
```kusto
Resources
| extend Tag1 = tags.Tag1
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| summarize Total=count() by tostring(SubName),tostring(subscriptionId),tostring(Tag1)
| order by SubName, Total
```

## Query which reports the unique tag value that has the maximum number of resources in each subscription. (Tag with the max count per subscription)
```kusto
Resources
| extend Tag1 = tags.Tag1
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| summarize Total=count() by tostring(SubName),tostring(Tag1),tostring(subscriptionId)
| summarize tot=arg_max(Total,Tag1,*) by SubName
| order by SubName, tot
```


## Query to report on the details of the AKS clustersin your tenant
```kusto

resources
| where type == "microsoft.containerservice/managedclusters"
| extend skuName = sku.name
| extend skuSLA = iff(sku.tier=="Paid","SLA (Paid Tier)","CostSavings (Free Tier)")
| extend networkPlugin = properties.networkProfile.networkPlugin
| extend networkPolicy = properties.networkProfile.networkPolicy
| extend powerState = properties.powerState.code
| extend provisionState = properties.provisioningState
| extend fqdn = properties.fqdn
| mv-expand ap = properties.agentPoolProfiles
| extend APName = ap.name
| extend APType = ap.type
| extend APOS = ap.osType
| extend APPowerState = ap.powerState.code
| extend APVmSize = ap.vmSize
| extend APMode = ap.mode
| extend APVersion = ap.orchestratorVersion
| extend APNodeVersion = ap.nodeImageVersion
| extend APAutoScale = ap.enableAutoScaling
| extend APOSDiskSize = ap.osDiskSizeGB
| extend APOSDiskType = ap.osDiskType
| extend APSubnetId = ap.vnetSubnetID
| extend APMaxPods = ap.maxPods
| extend APUltraDisk = ap.enableUltraSSD
| extend APMaxCount = ap.maxCount
| extend APMinCount = ap.minCount
| extend APOSSku = ap.osSKU
| extend NodeRG = properties.nodeResourceGroup
| extend maxAgentPools = properties.maxAgentPools
| extend enableRBAC = properties.enableRBAC
| extend scaledownutilizationthreshold = properties.autoScalerProfile.['scale-down-utilization-threshold']
| extend scaledowndelayafterfailure = properties.autoScalerProfile.['scale-down-delay-after-failure']
| extend skipnodeswithlocalstorage = properties.autoScalerProfile.['skip-nodes-with-local-storage']
| extend scaledowndelayafterdelete = properties.autoScalerProfile.['scale-down-delay-after-delete']
| extend maxgracefulterminationsec = properties.autoScalerProfile.['max-graceful-termination-sec']
| extend maxtotalunreadypercentage = properties.autoScalerProfile.['max-total-unready-percentage']
| extend balancesimilarnodegroups = properties.autoScalerProfile.['balance-similar-node-groups']
| extend skipnodeswithsystempods = properties.autoScalerProfile.['skip-nodes-with-system-pods']
| extend scaledowndelayafteradd = properties.autoScalerProfile.['scale-down-delay-after-add']
| extend scaledownunneededtime = properties.autoScalerProfile.['scale-down-unneeded-time']
| extend maxnodeprovisiontime = properties.autoScalerProfile.['max-node-provision-time']
| extend scaledownunreadytime = properties.autoScalerProfile.['scale-down-unready-time']
| extend newpodscaleupdelay = properties.autoScalerProfile.['new-pod-scale-up-delay']
| extend oktotalunreadycount = properties.autoScalerProfile.['ok-total-unready-count']
| extend maxemptybulkdelete = properties.autoScalerProfile.['max-empty-bulk-delete']
| extend scaninterval = properties.autoScalerProfile.['scan-interval']
| extend expander = properties.autoScalerProfile.['expander']
| extend linuxAdmin = properties.linuxProfile.adminUsername
| extend kubernetesVersion = properties.kubernetesVersion
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project name, location, resourceGroup, subscriptionId, SubName, skuName, skuSLA, networkPlugin, networkPolicy, provisionState, powerState, fqdn, APName, APType, APOS, APPowerState, APVmSize, APMode, APVersion, APNodeVersion, APAutoScale, APOSDiskSize, APOSDiskType, APSubnetId, APMaxPods, APUltraDisk, APMaxCount, APMinCount, APOSSku, NodeRG, maxAgentPools, enableRBAC, scaledownutilizationthreshold, scaledowndelayafterfailure, skipnodeswithlocalstorage, scaledowndelayafterdelete, maxgracefulterminationsec, maxtotalunreadypercentage, balancesimilarnodegroups, skipnodeswithsystempods, scaledowndelayafteradd, scaledownunneededtime, maxnodeprovisiontime, scaledownunreadytime, newpodscaleupdelay, oktotalunreadycount, maxemptybulkdelete, scaninterval, expander, linuxAdmin, kubernetesVersion
```
## Query which reports on the node types in all of the HDI Clusters
```kusto
resources
| where type == "microsoft.hdinsight/clusters"
| mv-expand roles = properties.computeProfile.roles
| extend rName = roles.name
| extend rSKU = roles.hardwareProfile.vmSize
| extend rInstanceCount = roles.targetInstanceCount
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project name, location, resourceGroup, SubName, subscriptionId, rName, rSKU, rInstanceCount
```
## Analyze the configuration of Azure VNET Gateways
```kusto
resources
| where type == "microsoft.network/virtualnetworkgateways"
| extend GWSKU = properties.sku.name
| extend GWCapacity = properties.sku.capacity
| extend GWTier = properties.sku.tier
| mv-expand GWtmp = properties.ipConfigurations
| extend GWPip = tostring(GWtmp.properties.publicIPAddress.id)
| join kind=leftouter (resources
| project PIPSku = (sku.name), PIPTier = (sku.tier), PIPZones = (zones), GWPip = tostring(id)) on GWPip
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project name, SubName, resourceGroup, location, GWSKU, GWCapacity, GWTier, PIPSku, PIPTier, PIPZones
```
## Produce VM List of all VMs in a set of subscriptions (including baremetal HLI systems)
NOTE: Replace "<< subid >>" with the subscription IDs that you want to look for. If you just want to look for one, you can make it a single value. Also note that the operating system information is coming from the resource provider which may not properly match that which is running on the server.
```kusto
resources
| where type == "microsoft.hanaonazure/hanainstances" or type == "microsoft.baremetalinfrastructure/baremetalinstances" or type == "microsoft.compute/virtualmachines"
| where subscriptionId in ("<< subid >>","<< subid >>","<< subid >>")
| extend SKU = case(properties.hardwareProfile.azureBareMetalInstanceSize <> "",properties.hardwareProfile.azureBareMetalInstanceSize,properties.hardwareProfile.hanaInstanceSize <> "",properties.hardwareProfile.hanaInstanceSize,properties.hardwareProfile.vmSize)
| extend OS = iif(properties.osProfile.osType=="",iif(properties.extended.instanceView.osName=="",strcat(properties.storageProfile.imageReference.publisher,"-",properties.storageProfile.imageReference.sku),strcat(properties.extended.instanceView.osName,"-",properties.extended.instanceView.osVersion)),properties.osProfile.osType)
| extend state = iif(properties.extended.instanceView.powerState.displayStatus=="",tostring(properties.powerState),properties.extended.instanceView.powerState.displayStatus)
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions'
| project SubscriptionName=name,subscriptionId) on subscriptionId
| project SubscriptionName, resourceGroup, name, SKU, OS, state, location
```

## Report on VNET configurations at scale
NOTE: This will produce a report that will have multiple entries for VNETs and Subnets depending on the number of service endpoints, and UDR Routes.
```kusto
resources
| where type == "microsoft.network/virtualnetworks"
| extend addressSpace = properties.addressSpace.addressPrefixes
| mv-expand subn = properties.subnets
| extend subnName = subn.name
| extend PrivateLinkServiceNetworkPolicies = subn.properties.privateLinkServiceNetworkPolicies
| extend PrivateEndpointNetworkPolicies = subn.properties.privateEndpointNetworkPolicies
| extend addressPrefix = subn.properties.addressPrefix
| extend servEchk = iif(subn.properties.serviceEndpoints=="[]",todynamic("None"),subn.properties.serviceEndpoints)
| mv-expand servE = servEchk
| extend serviceEndpoints = servE.service
| extend Delegchk = iif(subn.properties.delegations=="[]",todynamic("None"),subn.properties.delegations)
| mv-expand deleg = Delegchk
| extend delegService = deleg.properties.serviceName
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| extend SubnRTId = tostring(subn.properties.routeTable.id)
| join kind=leftouter (resources
| extend RTName = name
| mv-expand RT = properties.routes
| extend RTrName = RT.name
| extend RTPrefix = RT.properties.addressPrefix
| extend RTBGPOverride = RT.properties.hasBgpOverride
| extend RTNextHop = RT.properties.nextHopType
| project RTName, RTrName, RTPrefix, RTBGPOverride, RTNextHop, SubnRTId = (tostring(id))) on SubnRTId
| project name, location, SubName, resourceGroup, addressSpace, subnName, PrivateLinkServiceNetworkPolicies, PrivateEndpointNetworkPolicies, addressPrefix, serviceEndpoints, delegService, RTName, RTrName, RTPrefix, RTBGPOverride, RTNextHop 
```

## Report on Load Balancer Configuration at scale
```kusto
resources
| where type == "microsoft.network/loadbalancers"
| extend LbSku = sku.name
| extend LbTier = sku.tier
| mv-expand Lbr = properties.loadBalancingRules
| extend LbRuleName = Lbr.name
| extend LbRuleProtocol = Lbr.properties.protocol
| extend LbRuleIdleTimeout = Lbr.properties.idleTimeoutInMinutes
| extend lbRuleFloatingIp = Lbr.properties.enableFloatingIP
| extend lbRuleEnableTCPReset = Lbr.properties.enableTcpReset
| extend lbRuleFrontEndPort = Lbr.properties.frontendPort
| extend lbRuleHAPorts = iff((Lbr.properties.protocol=="All") and (Lbr.properties.frontendPort=="0"),"yes","no")
| extend lbdisableOutboundSnat = Lbr.properties.disableOutboundSnat
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions'
| project SubscriptionName=name,subscriptionId) on subscriptionId
| project name, SubscriptionName, resourceGroup, zones, LbSku, LbTier, LbRuleName, LbRuleProtocol, LbRuleIdleTimeout, lbRuleFloatingIp, lbRuleEnableTCPReset, lbRuleFrontEndPort, lbRuleHAPorts, lbdisableOutboundSnat
```

## Report on VM Configuration at scale
```kusto
resources
| where type == "microsoft.compute/virtualmachines" or type == "microsoft.baremetalinfrastructure/baremetalinstances"
| extend VMSize = iif(isempty(properties.hardwareProfile.vmSize),properties.hardwareProfile.azureBareMetalInstanceSize,properties.hardwareProfile.vmSize)
| extend ComputerName = properties.extended.instanceView.computerName
| extend OSName = properties.extended.instanceView.osName
| extend OSVersion = properties.extended.instanceView.osVersion
| extend ImgOSPublisher = properties.storageProfile.imageReference.publisher
| extend ImgOSOffer = properties.storageProfile.imageReference.offer
| extend ImgOSSKU = properties.storageProfile.imageReference.sku
| extend AvailSet = properties.availabilitySet.id
| extend PPG = properties.proximityPlacementGroup
| extend OSDiskName = properties.storageProfile.osDisk.name
| extend OSDiskId = tolower(tostring(properties.storageProfile.osDisk.managedDisk.id))
| join kind=leftouter (resources
| extend oSku = sku.name
| extend oSize = properties.diskSizeGB
| extend oIOPS = properties.diskIOPSReadWrite
| extend oMbps = properties.diskMBpsReadWrite
| extend oState = properties.diskState
| extend oTier = properties.tier
| extend OSDiskId = tolower(tostring(id))) on OSDiskId
| mv-expand dd = iff(tostring(properties.storageProfile.dataDisks)=="[]",parse_json('[0]'),properties.storageProfile.dataDisks)
| extend DataDiskName = dd.name
| extend DataDiskID = tolower(tostring(dd.managedDisk.id))
| extend DataDiskSize = dd.diskSizeGB
| extend DataDiskCache = dd.caching
| extend DataDiskLun = tostring(dd.lun)
| join kind=leftouter (resources
| extend dSku = sku.name
| extend dSize = properties.diskSizeGB
| extend dIOPS = properties.diskIOPSReadWrite
| extend dMbps = properties.diskMBpsReadWrite
| extend dState = properties.diskState
| extend dTier = properties.tier
| extend DataDiskID = tolower(tostring(id))) on DataDiskID
| extend cc = iff(isempty(properties.osProfile.linuxConfiguration),properties.osProfile.windowsConfiguration,properties.osProfile.linuxConfiguration)
| extend VMAgent = cc.provisionVMAgent
| extend PatchMode = cc.patchSettings.patchMode
| where ImgOSPublisher != "dellemc"
| extend VMName = name
| mv-expand nic = properties.networkProfile.networkInterfaces
| extend nicID = tostring(nic.id)
| join kind=leftouter (resources
| mv-expand ip = properties.ipConfigurations
| extend privateIP = ip.properties.privateIPAddress
| extend nicID = tostring(id)
| project nicID, privateIP) on nicID
| extend ipAddr = iff(isempty(nic.ipAddress),privateIP,nic.ipAddress)
| extend VMStatus = properties.extended.instanceView.powerState.displayStatus
| project VMName, ComputerName, location, resourceGroup, subscriptionId, VMSize, VMStatus, ipAddr, OSName, OSVersion, ImgOSPublisher, ImgOSOffer, ImgOSSKU, AvailSet, PPG, OSDiskName, oSize, oSku, oIOPS, oMbps, DataDiskName, dSize, dSku, dIOPS, dMbps, DataDiskCache, DataDiskLun, VMAgent, PatchMode
| order by VMName, DataDiskLun asc
```

## Report on NetApp Volume Configuration at scale
```kusto
resources
| where toupper(type) == toupper("microsoft.NetApp/netAppAccounts/capacityPools/Volumes")
| extend subnetId = properties.subnetId
| extend NetAppAccount = split(name,"/")[0]
| extend NetAppAccountPool = split(name,"/")[1]
| extend NetAppAccountVol = split(name,"/")[2]
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project NetAppAccount, NetAppAccountPool, NetAppAccountVol, SubName, subscriptionId, NetAppVolURI = id, subnetId
```

## Report on Log Analytics Workspaces daily cap settings
```kusto
resources
| where type == "microsoft.operationalinsights/workspaces"
| extend DataIngestionStatus = properties.workspaceCapping.dataIngestionStatus
| extend quotaNextResetTime = properties.workspaceCapping.quotaNextResetTime
| extend dailyQuotaGB = properties.workspaceCapping.dailyQuotaGb
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, subscriptionId) on subscriptionId
| project name, SubName, resourceGroup, DataIngestionStatus, quotaNextResetTime, dailyQuotaGB
```

## Report on ASR Configuraiton at scale
NOTE: There will be multiple lines per VM and disk because of the health of the VM. Parse the output with care. More information will be shared on how to best review the output of this query.
```kusto
RecoveryServicesResources
| where type == "microsoft.recoveryservices/vaults/replicationfabrics/replicationprotectioncontainers/replicationprotecteditems"
| extend policyName = properties.policyName
| extend protectionState = properties.protectionState
| extend currentProtectionState = properties.currentProtectionState
| extend protectionStateDescription = properties.protectionStateDescription
| extend recoveryAvailabilityZone = properties.providerSpecificDetails.recoveryAvailabilityZone
| extend primaryAvailabilityZone = properties.providerSpecificDetails.primaryAvailabilityZone
| extend lastRpoCalculatedTime = properties.providerSpecificDetails.lastRpoCalculatedTime
| extend datasourceType = properties.providerSpecificDetails.dataSourceInfo.datasourceType
| extend resourceLocation = properties.providerSpecificDetails.dataSourceInfo.resourceLocation
| extend resourceId = properties.providerSpecificDetails.dataSourceInfo.resourceId
| extend policyIda = tostring(properties.policyId)
| extend recoveryAzureVMSize = properties.providerSpecificDetails.recoveryAzureVMSize
| extend recoveryAzureVMName = tostring(properties.providerSpecificDetails.recoveryAzureVMName)
| extend failoverHealth = properties.failoverHealth
| mv-expand health = properties.healthErrors
| extend recommendedAction = health.recommendedAction
| extend possibleCauses = health.possibleCauses
| extend recoveryAzureVMtmp = split(resourceId, "/")
| extend recoveryAzureVMSub = tostring(recoveryAzureVMtmp[2])
| extend recoveryAzureVMRG = recoveryAzureVMtmp[4]
| mv-expand disks = properties.providerSpecificDetails.protectedManagedDisks
| extend diskName = disks.diskName
| extend diskState = disks.diskState
| extend diskId = disks.diskId
| extend recoveryTargetDiskAccountType = disks.recoveryTargetDiskAccountType
| extend instanceType = properties.instanceType
| join kind=leftouter (RecoveryServicesResources
| where type == "microsoft.recoveryservices/vaults/replicationpolicies"
| extend crashConsistentFrequencyInMinutes = properties.providerSpecificDetails.crashConsistentFrequencyInMinutes
| extend appConsistentFrequencyInMinutes = properties.providerSpecificDetails.appConsistentFrequencyInMinutes
| extend recoveryPointThresholdInMinutes = properties.providerSpecificDetails.recoveryPointThresholdInMinutes
| extend recoveryPointHistory = properties.providerSpecificDetails.recoveryPointHistory
| extend multiVmSyncStatus = properties.providerSpecificDetails.multiVmSyncStatus
| project policyIda=tostring(id), crashConsistentFrequencyInMinutes, appConsistentFrequencyInMinutes, recoveryPointThresholdInMinutes, recoveryPointHistory, multiVmSyncStatus) on policyIda
| join kind=leftouter (ResourceContainers 
| where type=='microsoft.resources/subscriptions' 
| project SubName=name, recoveryAzureVMSub=tostring(subscriptionId)) on recoveryAzureVMSub
| project recoveryAzureVMName, resourceLocation, SubName, recoveryAzureVMRG, policyName, protectionState, currentProtectionState, protectionStateDescription, recoveryAvailabilityZone, primaryAvailabilityZone, lastRpoCalculatedTime, failoverHealth, recommendedAction, possibleCauses, datasourceType, recoveryAzureVMSize, diskName, diskState, recoveryTargetDiskAccountType, crashConsistentFrequencyInMinutes, appConsistentFrequencyInMinutes, recoveryPointThresholdInMinutes, recoveryPointHistory, multiVmSyncStatus
| order by recoveryAzureVMName asc
```