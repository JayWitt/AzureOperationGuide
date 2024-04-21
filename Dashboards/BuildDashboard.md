# Build Metrics Dashboard
This script is used to dynamically create monitoring dashboards. You can use the following Resource Graph query to collect the Resource IDs of the servers that you would like to monitor and feed it to the script. A couple things to keep in mind:

* The script will split up the resources into groups of 10. 
* The following resource graph query will put everything into a single line and the results must be converted to be quoted with double quotes.
* The resource graph query is just an example to grab all of the servers in a single resource group, but can be adjusted to filter the query however you would like. The key output needed is the Resource ID.
* There are two fileds that need to be updated:
  * Dashboard Name: This is the variable that stores the name of the dashboard which is also used for the filename.
  * ListOfResources: This is the list of Resource IDs separated by commas. Each resource ID should have double quotes.
  * OutputFolder: This would be the folder location to save the final dashboard json file(s). This variable should NOT end in a slash.

```kusto
resources
| where type == "microsoft.compute/virtualmachines"
| where resourceGroup contains "Group1"
| summarize result = strcat_array(make_list(id), ",")
```

Example output from Resource Graph query (where the subscriptionID, resourcegroup name, and servername fields are replaced)
```kusto
"/subscriptions/<<subscriptionID1>>/resourceGroups/<<resourceGroupName1>>/providers/Microsoft.Compute/virtualMachines/<<servername1>>","/subscriptions/<<subscriptionID2>>/resourceGroups/<<resourceGroupName1>>/providers/Microsoft.Compute/virtualMachines/<<servername2>>"
```
