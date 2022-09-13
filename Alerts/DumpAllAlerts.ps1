
#Install-Module ExportExcel -AllowClobber -Force

$filename = "AllAlertReport.xlsx"

$searchLS = $true
$searchRH = $true
$searchM = $true
$searchAI = $true
$AllAG = $true


$AGList = @()

if ($searchLS) 
{
    $queryLS = "resources | where type == 'microsoft.insights/scheduledqueryrules' | mv-expand datasource = properties.scopes | extend ds1 = split(datasource,'/') | extend dsSub = ds1[2] | extend dsRG = ds1[4] | extend dsProv = ds1[6] | extend dsRes = ds1[8] | extend enabled = properties.enabled | extend severity = properties.severity | mv-expand  qu1 = properties.criteria.allOf | extend query = qu1.query | extend metric = qu1.metricName | mv-expand actionGroupID = properties.actions.actionGroups | extend linkID = toupper(tostring(actionGroupID)) | join kind=leftouter (resources | where type == 'microsoft.insights/actiongroups' | extend gName = name | extend linkID = toupper(tostring(id)) | project gName, linkID) on linkID | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=name, subscriptionId) on subscriptionId | project name, SubName, subscriptionId, resourceGroup, datasource, dsSub, dsRG, dsProv, dsRes, tostring(query), metric, severity, enabled, gName, linkID"

    $resultsLS = Search-AzGraph -query $queryLS -First 1000

    if ($resultsLS.count -eq 1000)
    {
        $rowcount = $resultsLS.Count
        $done = 0
        do {
            $tmpResults = Search-AzGraph -Query $queryLS -Skip $rowcount -First 1000
            $rowcount += $tmpResults.Count
            $resultsLS += $tmpResults
            if ($tmpResults.count -lt 1000) {$done = 1}
        }
        while ($done -eq 0)
    }


    $AGList += $($resultsLS.data.linkID | Sort-Object | Get-Unique)

    $resultsLS | Export-Excel $filename -Autosize -TableName "Log_Search_Alerts" -WorksheetName "Log_Search_Alerts"
}

if ($searchRH)
{

    $queryRH = "resources | where type == 'microsoft.insights/activitylogalerts' | extend alertnm = split(id,'/') | extend name = alertnm[8] | extend description = properties.description | extend enabled = properties.enabled | mv-expand actionGroupID = properties.actions.actionGroups | extend linkID = toupper(tostring(actionGroupID.actionGroupId)) | extend severity = properties.severity | extend condition = properties.condition | join kind=leftouter (resources | where type == 'microsoft.insights/actiongroups' | extend gName = name | extend linkID = toupper(tostring(id)) | project gName, linkID) on linkID | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=name, subscriptionId) on subscriptionId | project name, resourceGroup, SubName, subscriptionId, severity, enabled, tostring(condition), gName, linkID"

    $resultsRH = Search-AzGraph -query $queryRH -First 1000

    if ($resultsRH.count -eq 1000)
    {
        $rowcount = $resultsRH.Count
        $done = 0
        do {
            $tmpResults = Search-AzGraph -Query $queryRH -Skip $rowcount -First 1000
            $rowcount += $tmpResults.Count
            $resultsRH += $tmpResults
            if ($tmpResults.count -lt 1000) {$done = 1}
        }
        while ($done -eq 0)
    }

    $AGList += $($resultsRH.data.linkID | Sort-Object | Get-Unique)

    $resultsRH | Export-Excel $filename -Autosize -TableName "Resource_Service_Health_Alerts" -WorksheetName "R-S_Health_Alerts"
}

if ($searchM)
{

    $queryM = "resources | where type == 'microsoft.insights/metricalerts' | extend enabled = properties.enabled | mv-expand actionGroupID = properties.actions | extend linkID = toupper(tostring(actionGroupID.actionGroupId)) | extend severity = properties.severity | extend criteria = properties.criteria | mv-expand scp1 = properties.scopes | extend ds1 =split (scp1,'/') | extend dsSub = ds1[2] | extend dsRG = ds1[4] | extend dsProv = ds1[6] | extend dsRes = ds1[8] | extend description = properties.description | join kind=leftouter (resources | where type == 'microsoft.insights/actiongroups' | extend gName = name | extend linkID = toupper(tostring(id)) | project gName, linkID) on linkID | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=name, subscriptionId) on subscriptionId | project name, SubName, subscriptionId, severity, resourceGroup, description, dsSub, dsRG, dsProv, dsRes, tostring(criteria), enabled, gName, linkID"

    $resultsM = Search-AzGraph -query $queryM -First 1000

    if ($resultsM.count -eq 1000)
    {
        $rowcount = $resultsM.Count
        $done = 0
        do {
            $tmpResults = Search-AzGraph -Query $queryM -Skip $rowcount -First 1000
            $rowcount += $tmpResults.Count
            $resultsM += $tmpResults
            if ($tmpResults.count -lt 1000) {$done = 1}
        }
        while ($done -eq 0)
    }

    $AGList += $($resultsM.data.linkID | Sort-Object | Get-Unique)

    $resultsM | Export-Excel $filename -Autosize -TableName "Metrics_Alerts" -WorksheetName "Metrics_Alerts"
}

if ($SearchAI)
{
    $queryAI = "resources | where type == 'microsoft.alertsmanagement/smartdetectoralertrules' | extend alerttype = properties.detector.name | extend state = properties.state | extend severity = properties.severity | mv-expand scp1 = properties.scopes | extend ds1 =split (scp1,'/') | extend dsSub = ds1[2] | extend dsRG = ds1[4] | extend dsProv = ds1[6] | extend dsRes = ds1[8] | mv-expand actionGroupID = properties.actionGroups.groupIds | extend linkID = toupper(tostring(actionGroupID)) | join kind=leftouter (resources | where type == 'microsoft.insights/actiongroups' | extend gName = name | extend linkID = toupper(tostring(id)) | project gName, linkID) on linkID | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=name, subscriptionId) on subscriptionId | project name, SubName, subscriptionId, severity, resourceGroup, alerttype, state, tostring(gName), linkID"

    $resultsAI = Search-AzGraph -Query $queryAI -First 1000

    if ($resultsAI.count -eq 1000)
    {
        $rowcount = $resultsAI.Count
        $done = 0
        do {
            $tmpResults = Search-AzGraph -Query $queryAI -Skip $rowcount -First 1000
            $rowcount += $tmpResults.Count
            $resultsAI += $tmpResults
            if ($tmpResults.count -lt 1000) {$done = 1}
        }
        while ($done -eq 0)
    }

    $AGList += $($resultsAI.linkID | Sort-Object | Get-Unique)

    $resultsAI | Export-Excel $filename -Autosize -TableName "AppInsights_Alerts" -WorksheetName "AppInsights_Alerts"
}

if ($AllAG)
{
    $queryAG = "resources | where type == 'microsoft.insights/actiongroups' | extend RunbookReceivers = properties.automationRunbookReceivers | extend FunctionReceivers = properties.azureFunctionReceivers | extend AppPushReceivers = properties.azureAppPushReceivers | extend LogicAppReceivers = properties.logicAppReceivers | extend eventhubReceivers = properties.eventhubReceivers | extend webhookReceivers = properties.webhookReceivers | extend armRoleReceivers = properties.armRoleReceivers | extend voiceReceivers = properties.voiceReceivers | extend emailReceivers = properties.emailReceivers | extend smsReceivers = properties.smsReceivers | project name, id, tostring(AppPushReceivers), tostring(armRoleReceivers), tostring(emailReceivers), tostring(eventhubReceivers), tostring(FunctionReceivers), tostring(LogicAppReceivers), tostring(RunbookReceivers), tostring(smsReceivers), tostring(voiceReceivers), tostring(webhookReceivers)"
} else
{
    $AGListstr = "'$($AGList -join "','")'"
    $queryAG = "resources | where type == 'microsoft.insights/actiongroups' | extend RunbookReceivers = properties.automationRunbookReceivers | extend FunctionReceivers = properties.azureFunctionReceivers | extend AppPushReceivers = properties.azureAppPushReceivers | extend LogicAppReceivers = properties.logicAppReceivers | extend eventhubReceivers = properties.eventhubReceivers | extend webhookReceivers = properties.webhookReceivers | extend armRoleReceivers = properties.armRoleReceivers | extend voiceReceivers = properties.voiceReceivers | extend emailReceivers = properties.emailReceivers | extend smsReceivers = properties.smsReceivers | where toupper(id) in ($AGListstr) | project name, id, tostring(AppPushReceivers), tostring(armRoleReceivers), tostring(emailReceivers), tostring(eventhubReceivers), tostring(FunctionReceivers), tostring(LogicAppReceivers), tostring(RunbookReceivers), tostring(smsReceivers), tostring(voiceReceivers), tostring(webhookReceivers)"
}

$resultsAG = Search-AzGraph -Query $queryAG -First 1000

if ($resultsAG.count -eq 1000)
{
    $rowcount = $resultsAG.Count
    $done = 0
    do {
        $tmpResults = Search-AzGraph -Query $queryAG -Skip $rowcount -First 1000
        $rowcount += $tmpResults.Count
        $resultsAG += $tmpResults
        if ($tmpResults.count -lt 1000) {$done = 1}
    }
    while ($done -eq 0)
}

$resultsAG | Export-Excel $filename -Autosize -TableName "Action_Groups" -WorksheetName "Action_Groups"
