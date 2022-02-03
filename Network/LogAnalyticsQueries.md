
## Query the NSG Diagnostic logs for number of blocked matches
NOTE: This is not going against the NSG Flow logs but rather the diagnostic settings of the NSG. You won't see all of the detail but rather just the count of times that a rule was applied to block traffic. 
```kusto
AzureDiagnostics 
| where ResourceType=="NETWORKSECURITYGROUPS"
| where OperationName == "NetworkSecurityGroupCounters"
| where matchedConnections_d > 0
| where Resource == "<<Name of NSG>>"
| where type_s  == "block"
| summarize TotalMatched = sum(matchedConnections_d) by ruleName_s, direction_s, type_s, primaryIPv4Address_s
```