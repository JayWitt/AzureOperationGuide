# Build Metrics Dashboard
This [script](https://github.com/JayWitt/AzureOperationGuide/tree/master/Dashboards/BuildDashboard.ps1) is used to dynamically create monitoring dashboards. You can use the following Resource Graph query to collect the Resource IDs of the servers that you would like to monitor and feed it to the script. A couple things to keep in mind:

* The script will split up the resources into groups of 10. The script will append a number after each dashboard file created.
* The following resource graph query will put everything into a single line and the results must be converted to be quoted with double quotes. 
* The resource graph query is just an example to grab all of the servers in a single resource group, but can be adjusted to filter the query however you would like. The key output needed is the list of Resource IDs in an array.
* There are three fields that need to be updated:
  * Dashboard Name: This is the variable that stores the name of the dashboard which is also used for the filename.
  * ListOfResources: This is the list of Resource IDs separated by commas. Each resource ID should have double quotes.
  * OutputFolder: This would be the folder location to save the final dashboard json file(s). This variable should NOT end in a slash.
* Servers with more than 50 data disks will be limited to 50 disks. This is a limitation is also shown in the portal when setting up the split.
* Some metrics are in preview so in some cases data may be missing for those metrics. To identify the metrics in preview, you will need to click on the metric and view it in full screen as this will show you the system metric name which would include preview.

```kusto
resources
| where type == "microsoft.compute/virtualmachines"
| where resourceGroup contains "Group1"
| summarize result = strcat("'",strcat_array(make_list(id), "','"),"'")
```

Example output from Resource Graph query (where the subscriptionID, resourcegroup name, and servername fields are replaced)
```kusto
"/subscriptions/<<subscriptionID1>>/resourceGroups/<<resourceGroupName1>>/providers/Microsoft.Compute/virtualMachines/<<servername1>>","/subscriptions/<<subscriptionID2>>/resourceGroups/<<resourceGroupName1>>/providers/Microsoft.Compute/virtualMachines/<<servername2>>"
```
