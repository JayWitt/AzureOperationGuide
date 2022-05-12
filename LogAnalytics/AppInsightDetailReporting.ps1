
$tenantID = "<<tenant ID>>"  ## Replace <<tenant ID>> with the Azure Active Directory tenant ID that houses your Azure resources.

$context = Connect-AzAccount -Tenant $tenantID

$LAWsSub = Search-AzGraph -first 1000 -query 'resources | where type == "microsoft.operationalinsights/workspaces" | distinct subscriptionId'

$output = @()


foreach ($sub in $LAWsSub)
{
    $sub = $sub.subscriptionId

    Set-AzContext -Subscription $sub -Tenant $tenantID

    $LAWs = Search-AzGraph -first 1000 -Subscription $sub -query 'resources| where type == "microsoft.operationalinsights/workspaces"'

    foreach ($LAW in $LAWS)
    {
        $WorkspaceName = $LAW.name
        $ResourceGroupName = $LAW.resourceGroup

        write-host -ForegroundColor Yellow "Workspace: $WorkspaceName"

        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

        $query = 'union * | where TimeGenerated > ago(24h) | where _IsBillable == true | summarize IngestedVolume = sum(_BilledSize) by _ResourceId | where _ResourceId contains "microsoft.insights/components" | extend ResID = _ResourceId | sort by IngestedVolume desc'
 
        $QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query $query

        if ($($QueryResults.count) -gt 0)
        {

            foreach ($row in $($QueryResults.Results))
            {
                $resID = $row.ResID

                if ($resID -contains "microsoft.logic")
                {
                    $resID = $resID.Substring(0,$resID.IndexOf('/runs/'))
                }

                if ($resID -ne "")
                { 
                    $AppInsight = ""

                    write-output "Searching for $resID"
                    $query = "resources | where id endswith '$resID' | extend Tag1 = tags.Tag1 | extend Tag2 = tags.Tag2 | extend Tag3 = tags.Tag3 | extend Tag4 = tags.Tag4 | extend Tag5 = tags.Tag5"
                    $AppInsight = Search-AzGraph -query $query
       
                    $tmp = New-Object -TypeName psobject
                    $tmp | Add-Member -MemberType NoteProperty -Name LAWorkspaceName -Value $WorkspaceName
                    $tmp | Add-Member -MemberType NoteProperty -Name SubID -Value $sub
                    $tmp | Add-Member -MemberType NoteProperty -Name AppInsightInstance -Value $AppInsight.Name
                    $tmp | Add-Member -MemberType NoteProperty -Name IngestedVolumeInB -Value $row.IngestedVolume
                    $tmp | Add-Member -MemberType NoteProperty -Name IngestedVolumeInGB -Value $($row.IngestedVolume / 1024 / 1024 / 1024)
                    $tmp | Add-Member -MemberType NoteProperty -Name Tag1 -Value $AppInsight.Tag1
                    $tmp | Add-Member -MemberType NoteProperty -Name Tag2 -Value $AppInsight.Tag2
                    $tmp | Add-Member -MemberType NoteProperty -Name Tag3 -Value $AppInsight.Tag3
                    $tmp | Add-Member -MemberType NoteProperty -Name Tag4 -Value $AppInsight.Tag4
                    $output += $tmp

                }
            }
        }
    }
}

$output | Export-Csv -Path "AppInsightCostDetail.csv"