$tenantID = "<<tenantID>>"
$outfilename = "AppInsightDetail.csv"

$startTime = get-date
write-output "Starting @ $startTime"

$context = Connect-AzAccount -Tenant $tenantID

$AppSitesList = @()

$AppSites = Search-AzGraph -first 1000 -query 'resources | where type == "microsoft.web/sites" | project subscriptionId, resourceGroup, name | order by subscriptionId'

if ($AppSites.count -eq 1000)
{
    $rowcount = $AppSites.Count
    $done = 0
    do {
        $AppSites = Search-AzGraph -Query 'resources | where type == "microsoft.web/sites" | project subscriptionId, resourceGroup, name | order by subscriptionId' -Skip $rowcount -First 1000
        $rowcount += $AppSites.Count
        $AppSitesList += $AppSites
        if ($AppSites.count -lt 1000) {$done = 1}
    }
    while ($done -eq 0)
} else
{
    $AppSitesList = $AppSites
}

$maxCount = $AppSitesList.count
$counter = 0

$output = @()
$prevsub = $context.Context.Subscription.id

foreach ($app in $AppSitesList)
{
    $counter += 1 
    $perComp = ($counter / $maxCount) * 100
    write-progress -Activity "Collecting App Information" -PercentComplete $perComp
    $sub = $app.subscriptionId
    $rg = $app.resourceGroup
    $appName = $app.name

    write-host -ForegroundColor yellow "Collecting App [$appName]"

    if ($sub -ne $prevsub) {Set-AzContext -Subscription $sub -Tenant $tenantID}

    $prevsub = $sub

    $webApp = Get-AzWebApp -ResourceGroupName $rg -Name $appName 

    $AIKey = ""
    $AIAgentVersion = ""
    $AIMode = ""
    $AIBaseExt = ""
    $AIPreemptSDK = ""
    $AIJava = ""
    $AINodeJS = ""


    foreach ($setting in $($webApp.SiteConfig.AppSettings))
    {
        if ($setting.Name -eq "APPINSIGHTS_INSTRUMENTATIONKEY") {$AIKey = $setting.Value}
        if ($setting.Name -eq "ApplicationInsightsAgent_EXTENSION_VERSION") {$AIAgentVersion = $setting.Value}
        if ($setting.Name -eq "XDT_MicrosoftApplicationInsights_Mode") {$AIMode = $setting.Value}
        if ($setting.Name -eq "XDT_MicrosoftApplicationInsights_BaseExtensions") {$AIBaseExt = $setting.Value}
        if ($setting.Name -eq "XDT_MicrosoftApplicationInsights_PreemptSdk") {$AIPreemptSDK = $setting.Value}
        if ($setting.Name -eq "XDT_MicrosoftApplicationInsights_Java") {$AIJava = $setting.Value}
        if ($setting.Name -eq "XDT_MicrosoftApplicationInsights_NodeJS") {$AINodeJS = $setting.Value}
        if ($setting.Name -eq "APPINSIGHTS_PROFILERFEATURE_VERSION") {$AIProfileVer = $setting.Value}
        if ($setting.Name -eq "DiagnosticServices_EXTENSION_VERSION") {$DiagExtVer = $setting.Value}
        if ($setting.Name -eq "APPINSIGHTS_SNAPSHOTFEATURE_VERSION") {$AISnapshot = $setting.Value}
        if ($setting.Name -eq "SnapshotDebugger_EXTENSION_VERSION") {$SnapshotDebug = $setting.Value}
        if ($setting.Name -eq "InstrumentationEngine_EXTENSION_VERSION") {$InstExtVer = $setting.Value}
        $setting

    }

    $tmp = New-Object -TypeName psobject
    $tmp | Add-Member -MemberType NoteProperty -Name SubID -Value $sub
    $tmp | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $rg
    $tmp | Add-Member -MemberType NoteProperty -Name WebAppName -Value $appName
    $tmp | Add-Member -MemberType NoteProperty -Name InstrumentationKey -Value $AIKey
    $tmp | Add-Member -MemberType NoteProperty -Name AIAgent_Version -Value $AIAgentVersion
    $tmp | Add-Member -MemberType NoteProperty -Name AI_Mode -Value $AIMode
    $tmp | Add-Member -MemberType NoteProperty -Name AIBase_Extensions -Value $AIBaseExt
    $tmp | Add-Member -MemberType NoteProperty -Name AIPreemptSDK -Value $AIPreemptSDK
    $tmp | Add-Member -MemberType NoteProperty -Name AIJava -Value $AIJava
    $tmp | Add-Member -MemberType NoteProperty -Name AINodeJS -Value $AINodeJS
    $tmp | Add-Member -MemberType NoteProperty -Name AIProfileFeatureVer -Value $AIProfileVer
    $tmp | Add-Member -MemberType NoteProperty -Name DiagServExtVer -Value $DiagExtVer
    $tmp | Add-Member -MemberType NoteProperty -Name AISnapshotFeatureVer -Value $AISnapshot
    $tmp | Add-Member -MemberType NoteProperty -Name SnapshotDevugExtVer -Value $SnapshotDebug
    $tmp | Add-Member -MemberType NoteProperty -Name InstEngExtVer -Value $InstExtVer
    $output += $tmp

}

$output | Export-Csv -Path $outfilename -NoTypeInformation

$EndTime = get-date
$diff = $startTime - $EndTime
write-output "Ending @ $EndTime"
write-output "Difference: $diff"