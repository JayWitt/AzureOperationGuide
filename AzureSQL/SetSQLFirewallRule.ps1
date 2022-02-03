
$rootFWName = Read-Host "What should be used as the prefix to the Firewall rules? "
$RGName = Read-Host "What is the Resource Group Name that holds the SQL Server? "
$SQLServer = Read-Host "What is the name of the SQL server? "
$value = Read-Host "What are the IP ranges? "


$x=0
if ($value.IndexOf(",") -ne -1) 
{
    $arrValue = $value.split(",")
    foreach ($cell in $arrvalue)
    {
        $x +=1
        if ($cell.IndexOf("-") -eq -1)
        {
            $StartIP = $cell.trim()
            $EndIP = $cell.trim()

        } else
        {
            $StartIP = ($cell.Substring(0,$cell.IndexOf("-"))).Trim()
            $EndLength = $Cell.Length-$cell.IndexOf("-")-1
            $EndIP = ($cell.Substring($cell.IndexOf("-")+1,$EndLength)).Trim()
            

        }

        $Rulename = "$rootFWName$x"

        New-AzSqlServerFirewallRule -ResourceGroupName $RGName -ServerName $SQLServer -FirewallRuleName $RuleName -StartIpAddress $StartIP -EndIpAddress $EndIP


    }

}