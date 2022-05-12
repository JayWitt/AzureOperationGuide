# Useful tools and scripts to help understand costs

The following information can help to understand the costs and chargebacks related to Log Analytics.

## Charge Back teams for their use of Application Insights that puts its data in a centralized Log Analytics Workspace 

The following script can be used to enumerate all of the Log Analytics workspaces in the tenant that the script runner has access to. For each workspace, it looks for the usage information for any Application Insights instance and looks up the specific tag information about each instance. The resulting report can then be used to create a pivot table to show the rolled up costs by specific tags.

<center>
<a href='https://github.com/JayWitt/AzureOperationGuide/blob/main/LogAnalytics/AppInsightsDtailReport.ps1'>App Insights Detailed Reporting script</a>
</center>
<br>
NOTE: To run the script, change out the <<tenant>> reference to be the Azure Active Directory tenant ID that houses your Azure subscriptions.
