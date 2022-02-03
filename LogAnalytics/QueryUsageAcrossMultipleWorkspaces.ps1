Import-Module Az.ResourceGraph




$tenant = "<insert Tenant ID here>"

Connect-AzAccount -Tenant $tenant

$LAWsSub = Search-AzGraph -first 1000 -query 'resources | where type == "microsoft.operationalinsights/workspaces" | distinct subscriptionId'

foreach ($sub in $LAWsSub)
{
    $sub = $sub.subscriptionId

    Connect-AzAccount -Subscription $sub -Tenant $tenant

    $LAWs = Search-AzGraph -first 1000 -Subscription $sub -query 'resources| where type == "microsoft.operationalinsights/workspaces"'

    foreach ($LAW in $LAWS)
    {
        $WorkspaceName = $LAW.name
        $ResourceGroupName = $LAW.resourceGroup

        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

        $query = 'Usage | where TimeGenerated > ago(32d) | where StartTime >= startofday(ago(31d)) and EndTime < startofday(now()) | where IsBillable == true | summarize BillableDataGB = sum(Quantity) / 1000. by bin(StartTime, 1d), DataType'

        $QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query $query
        $QueryResults.Results | Export-Csv -Path "C:\Users\jawit\OneDrive - Microsoft\Walgreens\Questions\Log Analytics Usage\data\$sub-$WorkspaceName.csv"
    }
}