$tmp = Get-AzComputeResourceSku
$VMLookup = $tmp | Where-Object {($_.ResourceType -eq "VirtualMachines") -and ($_.Locations -eq "eastus")} | Sort-Object -Property Name
$output = $vmlookup | select-object -Property Size -ExpandProperty Capabilities | Where-Object {$_.Name -eq "CapacityReservationSupported"}

$output | Export-Csv ".\CRvms.csv"
