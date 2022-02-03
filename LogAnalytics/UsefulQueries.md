# Useful Log Analytics Queries

The following table contains useful Log Analytics Queries:
## List the free disk space of all computers in the workspace.
```kusto
Perf
| where ObjectName == "LogicalDisk" or ObjectName == "Logical Disk" 
| where CounterName == "Free Megabytes"
| summarize arg_max(TimeGenerated, *) by InstanceName 
| project Computer , TimeGenerated, InstanceName, CounterValue
```
## List free disk percentage of all computers in the workspace
```kusto
Perf
| where ObjectName == "LogicalDisk" or ObjectName == "Logical Disk" 
| where CounterName == "% Free Space" or CounterName == "% Used Space"
| summarize arg_max(TimeGenerated, *) by InstanceName
| project Computer , TimeGenerated, InstanceName, CounterValue
```
## Free Disk Percentage Alert Rule
```kusto
Perf
| where ObjectName == "LogicalDisk" or ObjectName == "Logical Disk"
| where CounterName == "% Free Space" or CounterName == "% Used Space"
| where CounterValue <= 20
| summarize arg_max(TimeGenerated, *) by InstanceName 
| project Computer, TimeGenerated, InstanceName, CounterValue
```
## Find Stale Computers:
The example finds computers that were active in the last day but did not send heartbeats in the last hour.
```kusto
Heartbeat 
| where TimeGenerated > ago(1d) 
| summarize LastHeartbeat = max(TimeGenerated) by Computer 
| where isnotempty(Computer) 
| where LastHeartbeat < ago(1h)
```
## Graph CPU Utilization Over past 4 hours
```kusto
Perf
| where TimeGenerated > ago(4h)
| where CounterName == @"% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 15m) 
| render timechart
```
## Determine Server Uptime over the past week
```kusto
let start_time=startofday(ago(5d));
let end_time=now();
Heartbeat
| where TimeGenerated > start_time and TimeGenerated < end_time
| summarize heartbeat_per_hour=count() by bin_at(TimeGenerated, 1h, start_time), Computer
| extend available_per_hour=iff(heartbeat_per_hour>0, true, false)
| summarize total_available_hours=countif(available_per_hour==true) by Computer 
| extend total_number_of_buckets=round((end_time-start_time)/1h)+1
| extend availability_rate=total_available_hours*100/total_number_of_buckets
```
## Determine Server Uptime over the past week in a Graph
```kusto
let start_time=startofday(ago(5d));
let end_time=now();
Heartbeat
| where TimeGenerated > start_time and TimeGenerated < end_time
| summarize heartbeat_per_hour=count() by bin_at(TimeGenerated, 1h, start_time), Computer
| extend available_per_hour=iff(heartbeat_per_hour>0, true, false)
| summarize total_available_hours=countif(available_per_hour==true) by Computer 
| extend total_number_of_buckets=round((end_time-start_time)/1h)+1
| extend availability_rate=total_available_hours*100/total_number_of_buckets
| project Computer, availability_rate 
| render barchart kind=default 
```
## Show the Activity Log entries for VM creation and deletion events along with the VM size
```kusto
AzureActivity 
| order by TimeGenerated
| where OperationNameValue == "Microsoft.Compute/virtualMachines/write" or OperationNameValue == "Microsoft.Compute/virtualMachines/delete"
| where ActivitySubstatus != ""
| extend VMSize = parse_json(tostring(parse_json(tostring(parse_json(tostring(parse_json(Properties).responseBody)).properties)).hardwareProfile)).vmSize
| project TimeGenerated, Resource, VMSize, OperationName
```
## List the login events for windows machines
Use this query to search for login events on all windows computes reporting within the scope defined when the query runs. The following table can help to decypher what type of login it is by referencing the Login Type code in the query output.
|Logon Type|Description|
|------|-----|
|2|Interactive (Logon at keyboard and screen)|
|3|Network (Connect to shared folder)|
|4|Batch (Scheduled task)|
|5|Service (Service startup)|
|7|Unlock (Unattended workstation with password protected screen)|
|8|NetworkClearText (Login with credentials sent in the clear)|
|9|NewCredentials (Runas or network drive with alternate credentials)|
|10|RemoteInteractive (Terminal Services, Remote Desktop, or Remote Assist)|
|11|CachedInteractive (Login with cached domain credentials)|

<https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4624>
```kusto
SecurityEvent 
| where ((EventID == 4624) or (EventID == 4634))
| project TimeGenerated, Activity , Account, LogonType, Computer
```
## View Performance Logs using Azure Metrics data
```kusto
AzureMetrics 
| where ResourceProvider == "MICROSOFT.COMPUTE"
| where MetricName == "Percentage CPU"
| project Resource, ResourceGroup, SubscriptionId, Total
```
## View Performance Logs using Perf table (i.e. Azure WAD Agent)
```kusto
Perf 
| where ObjectName == "Processor"
| where CounterName == "% Processor Time"
| extend VM = split(_ResourceId,"/")
| extend SubscriptionID = VM[2]
| extend ResourceGroup = VM[4]
| project Computer, ResourceGroup, SubscriptionID, CounterValue
```
## View App Gateway logs to determine rewrite rule processing
```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS" and OperationName == "ApplicationGatewayAccess"
| where TimeGenerated >= ago(20m)
| project TimeGenerated, originalHost_s, host_s, serverRouted_s, serverStatus_s, userAgent_s, requestUri_s, originalRequestUriWithArgs_s, backendPoolName_s, backendSettingName_s, ruleName_s, listenerName_s
| order by TimeGenerated 
```