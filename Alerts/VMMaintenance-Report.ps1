
$subs = @('<subscription ID #1>','<subscription ID #2>')
$loc = "<Azure Region shorthand (i.e. centrlaus)>"

$output = @()
$outputfull = @()

Foreach ($subId in $subs)
{
    set-azcontext -Subscription $subId -WarningAction SilentlyContinue

    $query = "resources | where type == 'microsoft.compute/virtualmachines' | where subscriptionId == '$subID' | where location == '$loc' | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubscriptionName=name,subscriptionId) on subscriptionId | project SubscriptionName, resourceGroup, name"

    $results = Search-AzGraph -query $query -First 1000

    if ($results.count -eq 1000)
    {
        $rowcount = $results.Count
        $done = 0
        do {
            $tmpResults = Search-AzGraph -Query $query -Skip $rowcount -First 1000
            $rowcount += $tmpResults.Count
            $results += $tmpResults
            if ($tmpResults.count -lt 1000) {$done = 1}
        }
        while ($done -eq 0)
    }

    write-host -ForegroundColor Magenta "Query: $query"
    write-host -ForegroundColor Green "Count: $($results.count)"

    foreach ($vm in $results)
    {
        $mainAllow = ""
        $preMainStart = ""
        $preMainEnd = ""
        $mainStart = ""
        $mainEnd = ""

        $VMName = $vm.Name
        $VMRG = $vm.resourceGroup
        $SubName = $vm.SubscriptionName

        $tmp = Get-AzVM -ResourceGroupName $VMRG -Name $VMName -Status -ErrorAction SilentlyContinue
        $mainAllow = $tmp.MaintenanceRedeployStatus.IsCustomerInitiatedMaintenanceAllowed
        $preMainStart = $tmp.MaintenanceRedeployStatus.PreMaintenanceWindowStartTime
        $preMainEnd = $tmp.MaintenanceRedeployStatus.PreMaintenanceWindowEndTime
        $mainStart = $tmp.MaintenanceRedeployStatus.MaintenanceWindowStartTime
        $mainEnd = $tmp.MaintenanceRedeployStatus.MaintenanceWindowsEndTime
        $LastOpCode = $tmp.MaintenanceRedeployStatus.LastOperationResultCode
        $LastOpMsg = $tmp.MaintenanceRedeployStatus.LastOperationMessage

        write-host "$VMName - $mainAllow - $preMainStart"
        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name SubName -Value $subName
        $obj | Add-Member -MemberType NoteProperty -Name SubID -Value $subID
        $obj | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $VMRG
        $obj | Add-Member -MemberType NoteProperty -Name VMName -Value $VMName
        $obj | Add-Member -MemberType NoteProperty -Name PremtiveStart -Value $preMainStart
        $obj | Add-Member -MemberType NoteProperty -Name PremtiveEnd -Value $preMainEnd
        $obj | Add-Member -MemberType NoteProperty -Name MainStart -Value $MainStart
        $obj | Add-Member -MemberType NoteProperty -Name MainEnd -Value $MainEnd
        $obj | Add-Member -MemberType NoteProperty -Name LastOperationResultCode -Value $LastOpCode
        $obj | Add-Member -MemberType NoteProperty -Name LastOperationMessage -Value $LastOpMsg

        $outputfull += $obj

        if (($preMainEnd -gt (get-date)) -or ($MainEnd -gt (get-date)))
        {
            $output += $obj
        }
    }

}

