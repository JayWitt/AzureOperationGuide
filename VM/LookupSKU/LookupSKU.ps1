param(
    [parameter(Mandatory=$true)][string]$location,
    [parameter(Mandatory=$true)][string]$LookupVMSKU
    ) 

#$location = "eastus"
#$LookupVMSKU = "Standard_D4"

if ($LookupVMSKU.IndexOf("Standard") -lt 0) {$LookupVMSKU = "Standard_$LookupVMSKU"}

$PriceListPath = "$PSScriptRoot\LookupSKU_PriceList-$location.csv"
$outputfilepath = "$PSScriptRoot\LookupSKU_Full-$location.csv"
$needNewVMFile = $true
$needNewPriceFile = $true

if (Test-Path -path $outputfilepath) {
    if ((Get-ChildItem $outputfilepath).LastWriteTime -gt (get-Date).AddDays(-30)){
        $output = (Get-Content -Path $outputfilepath) | convertfrom-Csv
        $needNewVMFile = $false
    }
}

if (Test-Path -Path $PriceListPath) {
    if ((Get-ChildItem $PriceListPath).LastWriteTime -gt (get-Date).AddDays(-30)){
        $priceList = (Get-Content -Path $PriceListPath) | convertfrom-Csv
        $needNewPriceFile = $false
    }
}

if ($needNewVMFile -or $needNewPriceFile)
{
    write-host -ForegroundColor Cyan "Saved Data older than 30 days or not found. Downloading new VM and Pricing data for $location region."

    write-host -ForegroundColor Cyan "Collecting VM Pricing Information"
    $prices = @{}
    $url = "https://prices.azure.com/api/retail/prices?`$filter=armRegionName eq '$location' and pricetype eq 'Consumption' and serviceName eq 'Virtual Machines'"
    #$url = "https://prices.azure.com/api/retail/prices?`$filter=pricetype eq 'Consumption' and serviceName eq 'Virtual Machines'"
    $webReq = (Invoke-WebRequest -Uri $url).content | ConvertFrom-Json
    $priceList = $webReq.Items
    $estimatedCount

    Do 
    {
        #173400 VM options for all regions (Approx.)
        #4500 VM options per region (Approx.)
        $perComplete = [math]::Round((($Pricelist.Count)/4500)*100)
        Write-Progress -Activity "Collection in progress" -PercentComplete $perComplete
        $webReq = (Invoke-WebRequest -Uri $webReq.NextPageLink).content | ConvertFrom-Json
        $priceList += $webReq.Items

    } While ($webReq.Count -eq 100)

    $priceList | Export-Csv -Path $PriceListPath -NoTypeInformation

    write-progress -Activity "Collection in progress" -Completed

    write-host -ForegroundColor Cyan "Collecting VM Information"
    $fulllist = Get-AzComputeResourceSku -location $location

    $output = @()
    write-host -ForegroundColor Cyan "Building VM List"
    foreach ($row in $fulllist)
    {
        $resourceType  = $row.ResourceType
        if ($resourceType -eq "virtualMachines")
        {
            $SKU = $row.Name
            write-host -ForegroundColor Cyan "Processing [$SKU]"

            $obj = New-Object -TypeName psobject
            $obj | Add-Member -MemberType NoteProperty -Name SKU -Value $SKU
            $obj | Add-Member -MemberType NoteProperty -Name Region -Value $($row.locations)
            $obj | Add-Member -MemberType NoteProperty -Name Zones -Value $($row.locationInfo.zones -join ",")
            foreach ($innerRow in $row.Capabilities){
                [string]$CapabilityName = $innerRow.Name
                [string]$Capabilityvalue = $innerRow.Value

                if ($CapabilityName -eq "CombinedTempDiskAndCachedReadBytesPerSecond") {
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CombinedTempDiskAndCachedReadMBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($Capabilityvalue / 1024 / 1024)}
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CombinedTempDiskAndCachedReadMiBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($innerRow.Value / 1000 / 1000)}
                }
                if ($CapabilityName -eq "CombinedTempDiskAndCachedWriteBytesPerSecond") {
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CombinedTempDiskAndCachedWriteMBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($Capabilityvalue / 1024 / 1024)}
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CombinedTempDiskAndCachedWriteMiBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($innerRow.Value / 1000 / 1000)}
                }
                if ($CapabilityName -eq "UncachedDiskBytesPerSecond") {
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "UncachedDiskMBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($Capabilityvalue / 1024 / 1024)}
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "UncachedDiskMiBPerSecond"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($innerRow.Value / 1000 / 1000)}
                }
                if ($CapabilityName -eq "CachedDiskBytes") {
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CachedDiskMB"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($Capabilityvalue / 1024 / 1024)}
                    $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
                    $CapabilityName = "CachedDiskMiB"
                    if ($Capabilityvalue -ne "") {$Capabilityvalue = ($innerRow.Value / 1000 / 1000)}
                }
                $obj | Add-Member -MemberType NoteProperty -Name $CapabilityName -Value $Capabilityvalue
            }

            $x = 1
            foreach ($restriction in $row.Restrictions)
            {
                $reasonCode = $restriction.reasoncode
                $restrictArray = $restriction.RestrictionInfo
                $Arrayheaders = $restrictArray | get-member | Where-Object {$_.MemberType -eq 'Property'}
                foreach ($entry in $restrictArray)
                {
                    $restrictionDescription = ""
                    ForEach ($header in $Arrayheaders)
                    {
                        if ($($Header.Name).Length -ne 0){$restrictionDescription += "$($Header.Name) = $($entry.$($header.name));"}
                    }
                }
                if ($restrictionDescription.Length -ne 0) {$obj | Add-Member -MemberType NoteProperty -Name "Restrictions[$x]" -Value $restrictionDescription}
                $x += 1
            }

            $VMBill = $priceList | Where-Object {$_.armSkuName -eq $SKU -and $_.armRegionName -eq $location -and -not ($_.productName -match 'Windows') -and -not ($_.meterName -match 'Low Priority') -and -not ($_.meterName -match 'Spot')}

            $obj | Add-Member -MemberType NoteProperty -Name "RetailHourlyPrice" -Value $VMBill.retailPrice
            $obj | Add-Member -MemberType NoteProperty -Name "RetailMonthlyPrice" -Value ($VMBill.retailPrice * 730)

            $output += $obj

        }
    }

    $output | Export-Csv -Path $outputfilepath -NoTypeInformation
}


Function FormatOutput {
    param (
        $outKey,
        $outValue
        )

    $results = $outkey+$outValue.PadLeft(45) 

}

$result = $output | Where-Object {$_.SKU -eq $LookupVMSKU} | Sort-Object -Property Name

if ($result -ne $null) {
    write-host -ForegroundColor Cyan "SKU Price"

    write-host -ForegroundColor White "SKU: $($($result.SKU).PadLeft(48-3))"

    Foreach ($property in $($result | get-member | where-object {$_.MemberType -eq 'NoteProperty'}))
    {
        if ($property.Name -ne "SKU") {
            Switch -Wildcard ($property.Name)
            {
                "Restrictions*" {
                                if ($($result.$($property.name)) -ne "")
                                {
                                    write-host -ForegroundColor White "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                                }
                            }
                "CombinedTempDiskAndCachedReadMBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "CombinedTempDiskAndCachedReadMiBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "CombinedTempDiskAndCachedWriteMBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "CombinedTempDiskAndCachedWriteMiBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "MaxDataDiskCount" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "MaxNetworkInterfaces" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "MemoryGB" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "vCPUs" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "RetailMonthlyPrice" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "UnachedDiskIOPS" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "UncachedDiskMBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                "UncachedDiskMiBPerSecond" {
                        write-host -ForegroundColor Yellow "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                            }
                Default {
                        write-host -ForegroundColor White "$($property.Name): $($($result.$($property.name)).PadLeft(48-$($property.Name).Length))"
                    }

            }
        }  
    }
}



        