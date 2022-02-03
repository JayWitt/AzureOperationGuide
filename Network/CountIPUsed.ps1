# Sample scripts are not supported under any Microsoft standard support program or service. 
# The sample scripts are provided AS IS without warranty of any kind. Microsoft disclaims all 
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample scripts and documentation remains with you. In no event shall Microsoft, its 
# authors, or anyone else involved in the creation, production, or delivery of the scripts be 
# liable for any damages whatsoever (including, without limitation, damages for loss of business
# profits, business interruption, loss of business information, or other pecuniary loss) arising
# out of the use of or inability to use the sample scripts or documentation, even if Microsoft 
# has been advised of the possibility of such damages.

$VNETs=Get-AzVirtualNetwork 

$output = @()
foreach ($VNET in $VNETs) 
{
    $VNetName = $VNET.Name
    $result=Get-AzVirtualNetwork -Name $VNET.Name -ResourceGroupName $VNET.ResourceGroupName -ExpandResource 'subnets/ipConfigurations' 
    foreach ($obj in $result)
    {
        foreach ($subnet in $obj.Subnets)
        {
            $ipAddrTotal = [Math]::Pow(2,(32 - ($subnet.AddressPrefix.split("/")[1]))) -5
            $SubnetName = $subnet.Name
            $SubnetCount = $subnet.IpConfigurations.count

            $RemainingIPCount = $ipAddrTotal - $SubnetCount

            $record = New-Object -TypeName psobject
            $record | Add-Member -MemberType NoteProperty -Name VNETName -value $VNETName
            $record | Add-Member -MemberType NoteProperty -Name SubnetName -value $SubnetName
            $record | Add-Member -MemberType NoteProperty -Name TotalIPAllocated -value $ipAddrTotal
            $record | Add-Member -MemberType NoteProperty -Name UsedIPs -value $SubnetCount
            $record | Add-Member -MemberType NoteProperty -Name AvailableIps -value $RemainingIPCount

            $output += $record
       }
    }
}

$output | ft
