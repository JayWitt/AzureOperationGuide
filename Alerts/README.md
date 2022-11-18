# Azure Alerts


You can use the [DumpAllAlertsByEmail](https://github.com/JayWitt/AzureOperationGuide/blob/master/Alerts/DumpAllAlertsByEmail.ps1) to get the list of alert rules that have been setup with an action group that contains the e-mail address specified by the $email variable.


You can use the [DumpAllAlerts](https://github.com/JayWitt/AzureOperationGuide/blob/master/Alerts/DumpAllAlerts.ps1) to get the list of all of the alert rule types. 

NOTE: That you will need to install the [ExportExcel](https://www.powershellgallery.com/packages/ImportExcel/1.90/Content/Export-Excel.ps1) Powershell module.


# VM Maintenance

You can use the [VMMaintenance-Report](https://github.com/JayWitt/AzureOperationGuide/blob/master/Alerts/VMMaintenance-Report.ps1) script to get a list of VMs that are going to be impacted by planned maintenance. The script has two sets of variables that would need to be updated. You would need to enter in the subscription ID(s) of the subscriptions that you would want to search through and also provide the region. This script is meant to be helpful to respond to specific Service Health Alerts that report planned maintenance on a subset of VMs.

The $output variable will store the list of machines that have maintenance coming up in the future.
The $outputfull variable will store the full list of VMs in the subscription and region specified.