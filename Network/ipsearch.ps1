param([parameter(Mandatory=$true)][string]$srcip) 

try
    {
        [IpAddress]$srcip | Out-Null
    }
catch
    {

        #$(foreach ($range in $((get-aznetworkservicetag -location eastus).values)) {$range.Properties.AddressPrefixes}) | where-object {$_ -match "13.72"}

        $dns = resolve-dnsname $srcip
        if ($dns.IP4Address.Count -eq 1)
            {
                $srcip = $dns.IpAddress
            }
        else
            {
                $srcip = $dns.IpAddress[0]
            }
    }

# You can get this API key from https://ipgeolocation.io/
$apikey = "<<apikey>>"

$finalRegion = "Not in Azure"
$finalSubnet = "Not in Azure"
$finalService = "Not in Azure"

$result = Invoke-WebRequest -Uri "https://www.azurespeed.com/api/ipinfo?ipAddressOrUrl=$srcip"
$output = $result.Content | convertfrom-json

$Region = $output.region
$prefix = $output.ipAddressPrefix
$service = $output.systemService

if ($Region -ne "") 
    {
        $finalRegion = $Region
        $finalSubnet = "In Azure"
        $finalService = "General Azure"
    }
if ($prefix -ne "") {$finalSubnet = $prefix}
if ($service -ne "") {$finalService = $service}


write-host "$srcip is in:" -ForegroundColor Yellow
write-host "   Region: $finalRegion" -ForegroundColor Cyan
write-host "   Subnet: $finalsubnet" -ForegroundColor Cyan
write-host "   Service: $finalService" -ForegroundColor Cyan
write-host ""

if ($finalsubnet -eq "Not in Azure"){
    $url = "https://api.ipgeolocation.io/ipgeo?apiKey=$apikey&ip=$srcip"

    $request = Invoke-WebRequest -Uri $url 
    $value = $request.Content | convertfrom-json
    $country = $value.country_name
    $continent = $value.continent_name
    $city = $value.city
    $state = $value.state_prov
    $isp = $value.isp

    write-host "   GeoLocation:" -ForegroundColor Yellow
    write-host "      Country: $country" -ForegroundColor Cyan
    write-host "      State: $state" -ForegroundColor Cyan
    write-host "      City: $city" -ForegroundColor Cyan
    write-host "      Continent: $continent" -ForegroundColor Cyan 
    write-host "      ISP: $isp" -ForegroundColor Cyan 
}