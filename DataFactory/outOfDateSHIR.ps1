$tenantID = "<tenant ID>"

Connect-AzAccount -Tenant $tenantID

$output = @()

$query = "resources | where type == 'microsoft.datafactory/factories' | join kind=leftouter (ResourceContainers | where type=='microsoft.resources/subscriptions' | project SubName=name, subscriptionId) on subscriptionId"

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

$prevSubID = ""

foreach ($df in $results)
{

    $dfName = $df.name
    $dfRG = $df.resourceGroup
    $dfSub = $df.subscriptionId
    $dfSubName = $df.SubName

    if ($dfSub -ne $prevSubID) 
    {
        set-azcontext -Subscription $dfSub -WarningAction SilentlyContinue
        $prevSubID = $dfSub
    }

    $dfIR = Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $dfRG -DataFactoryName $dfName

    foreach ($IR in $dfIR)
    {
        $IRobj = Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $dfRG -DataFactoryName $dfName -Name $($IR.Name) -Status

        write-host -ForegroundColor Yellow "Evaluating [$dfName]"
        $IRtype = $IRobj.Type
        $IRVersion = $IRobj.Version
        $IRLatestVersion = $IRObj.LatestVersion
        $IRDelta = ""

        if ($IRType -eq "SelfHosted") 
        {
            if ($IRVersion -ne $IRLatestVersion)
            {
                write-host -ForegroundColor Red "[SHIR] $($IR.Name) [$IRVersion] NEED TO UPGRADE TO $IRLatestVersion!"
                $IRDelta = "Need to upgrade"
            } else
            {
                write-host -ForegroundColor Green "[SHIR] $($IR.Name) [$IRVersion]"
            }
        } else
        {
            write-host -ForegroundColor Green "[$IRType] $($IR.Name)"
        }

        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name SubName -Value $dfSubName
        $obj | Add-Member -MemberType NoteProperty -Name SubID -Value $dfSub
        $obj | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $dfRG
        $obj | Add-Member -MemberType NoteProperty -Name FactoryName -Value $dfName
        $obj | Add-Member -MemberType NoteProperty -Name RuntimeName -Value $IR.Name
        $obj | Add-Member -MemberType NoteProperty -Name RuntimeType -Value $IRType
        $obj | Add-Member -MemberType NoteProperty -Name RuntimeVersion -Value $IRVersion
        $obj | Add-Member -MemberType NoteProperty -Name RuntimeLatest -Value $IRLatestVersion
        $obj | Add-Member -MemberType NoteProperty -Name RuntimeDelta -Value $IRDelta


        $output += $obj
        
    }
}

$output | Export-Csv -Path SHIR.csv -NoTypeInformation


