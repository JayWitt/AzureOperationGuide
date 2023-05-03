

$connect = Connect-AzAccount 
$tenantID = (get-aztenant -ErrorAction SilentlyContinue | Out-GridView -OutputMode single -Title "Select tenant ID").id
$out = set-azcontext -Tenant $tenantID 

$subID = ""
$subID = (Get-AzSubscription -TenantId $tenantID | Out-GridView -OutputMode single -Title "Select Subscription").id

$output = ""
if ($subID -ne "")
{
    $out = set-azcontext -subscription $subid -Tenant $tenantID 
    $subName = $out.Name

    $tokObj = get-AzAccessToken -TenantId $tenantID
    $token = $tokObj.Token

    $FeatureStatus = (get-azproviderfeature -listavailable -ProviderNamespace Microsoft.Resources | where-object {$_.FeatureName -eq "AvailabilityZonePeering"}).RegistrationState

    if ($FeatureStatus -eq "Registered")
    {

        $requestHeader = @{
        "x-ms-version" = "2014-10-01";
        "Content-Type" = "application/json";
        "Authorization" = "Bearer $token"
        }

        $body = "
        {'location':'westus',
        'subscriptionIds':['subscriptions/$subID']
        }"


        $url = "https://management.azure.com/subscriptions/$subid/providers/Microsoft.Resources/checkZonePeers/?api-version=2020-01-01"

        $output = Invoke-RestMethod -Method Post -uri $url -Body $body -Headers $requestHeader

        write-output "$subName ($subid) mapping:"
        foreach ($az in $($output.availabilityZonePeers))
        {
            $logicalAZ = $az.AvailabilityZone
            $physicalAZ = $az.peers.availabilityZone

            write-output "Logical Zone $logicalAZ --> Physical Zone $physicalAZ"
        }
    } else
    {
        write-host -ForegroundColor Cyan "AvailabilityZonePeering feature is not registered. Please register it first before running the script.`n`rFor more information view here: https://learn.microsoft.com/en-us/rest/api/resources/subscriptions/check-zone-peers?tabs=HTTP"
    }
} else
{
        write-host -ForegroundColor Cyan "Unable to get subscription information. Please check access to the selected tenant and/or subscription."
}