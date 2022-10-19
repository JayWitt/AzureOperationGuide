param ([string]$name)

try {
    $tmp = [ipaddress]$name
    $ip = $tmp.IPAddressToString
    $tmp = Resolve-DnsName $name -ErrorAction SilentlyContinue
    $name = $tmp.NameHost + "(" + $name + ")"
}
catch
{
    $tmp = test-connection $name -count 1
    $ip = $tmp.IPV4Address.IPAddressToString
}

$url = "http://whois.arin.net/rest/ip/$ip"

$headers = @{
"Accept" = "application/json"
}
$output = Invoke-WebRequest -Uri $url -Headers $headers 
$jsonobj = convertfrom-json $output.Content
$OrgName = $jsonobj.net.orgRef.'@name'
if ($OrgName -eq $null) {$OrgName = $jsonobj.net.customerRef.'@name'}

$NetName = $jsonobj.net.name.'$'


write-output "$name is owned by $OrgName / $NetName"