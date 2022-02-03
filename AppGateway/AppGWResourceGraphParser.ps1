#
# Resource Graph Query:
#      resources
#      | where type == "microsoft.network/applicationgateways"
#
#
#


$ResourceGraphOutputPath = "<inputfilepath>"
$outputPath = "<outpufilepath>"


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


$file = get-content -Path $ResourceGraphOutputPath

$obj = $file | convertfrom-csv

$table = @()

foreach ($row in $obj) 
{
    $backendHttpSettingsCollection = @{}
    $backendAddressPools = @{}
    $requestRoutingRules = @{}
    $frontendIPConfigurations = @{}
    $urlPathMaps = @{}
    $sslCertificates = @{}
    $httpListeners = @{}
    $probes = @{}
    $gatewayIPConfigurations = @{}
    $redirectConfigurations = @{}
    $rewriteRuleSets = @{}
    $frontendPorts = @{}
    $authenticationCertificates = @{}

    $appGWName = ""
    $appGWRG = ""
    $appGWSubID = ""
    $appGWProvisioningState = ""
    $appGWOperationalState = ""
    $appGWSku = ""
    $appGWTier = ""
    $appGWCapacity = ""
    $realFrontEndIP = ""
    $realListenerName = ""
    $realRequestRoutingRuleName = ""
    $realhttpSettingName = ""
    $realProtocol = ""
    $realHttpProvisioning = ""
    $realRedirectType = ""
    $RealBackendPoolName = ""
    $RealBackendPoolAddresses = ""
    $RealProbeName = ""
    $realProbeHostname = ""
    $RealProbepath = ""
    $RealProbeMatch = ""

    $appGWName = $row.NAME
    $appGWRG = $row.RESOURCEGROUP
    $appGWSubID = $row.SUBSCRIPTIONID
    $appgwobj = $row.PROPERTIES | Convertfrom-Json
    $appGWProvisioningState = $appgwobj.provisioningState
    $appGWOperationalState = $appgwobj.operationalState
    $appGWSKU = $appgwobj.sku.name
    $appGWTier = $appgwobj.sku.tier
    $appGWCapacity = $appgwobj.sku.capacity

    foreach ($bap in $appgwobj.backendAddressPools)
    {
        $backendAddressPools.Add($bap.id,$bap)
    }

    foreach ($rrr in $appgwobj.requestRoutingRules)
    {
        $requestRoutingRules.Add($rrr.id,$rrr)
    }

    foreach ($feipc in $appgwobj.frontendIPConfigurations)
    {
        $frontendIPConfigurations.Add($feipc.id,$feipc)
    }

    foreach ($upm in $appgwobj.urlPathMaps)
    {
        $urlPathMaps.Add($upm.id,$upm)
    }

    foreach ($sslc in $appgwobj.sslCertificates)
    {
        $sslCertificates.Add($sslc.id,$sslc)
    }

    foreach ($hl in $appgwobj.httpListeners)
    {
        $httpListeners.Add($hl.id,$hl)
    }

    foreach ($p in $appgwobj.probes)
    {
        $probes.Add($p.id,$p)
    }

    foreach ($behs in $appgwobj.backendHttpSettingsCollection)
    {
        $backendHttpSettingsCollection.Add($behs.id,$behs)
    }

    foreach ($gipc in $appgwobj.gatewayIPConfigurations)
    {
        $gatewayIPConfigurations.Add($gipc.id,$gipc)
    }

    foreach ($rc in $appgwobj.redirectConfigurations)
    {
        $redirectConfigurations.Add($rc.id,$rc)
    }

    foreach ($rrs in $appgwobj.rewriteRuleSets)
    {
        $rewriteRuleSets.Add($rrs.id,$rrs)
    }

    foreach ($fep in $appgwobj.frontendPorts)
    {
        $frontendPorts.Add($fep.id,$fep)
    }

    foreach ($ac in $appgwobj.authenticationCertificates)
    {
        $authenticationCertificates.Add($ac.id,$ac)
    }


    foreach ($listener in $appgwobj.httpListeners)
    {
        $tmpIP = $frontendIPConfigurations[$listener.properties.frontendIPConfiguration.id].properties
        if ($tmpIP.privateIPAddress -eq $null) 
            {
                $realFrontEndIP = $tmpIP.publicIPAddress.id
            }
            else
            {
                $realFrontEndIP = $tmpIP.privateIPAddress
            }

        $realListenerName = $httpListeners[$listener.id].name

        foreach ($rule in $httpListeners[$listener.id].properties.requestRoutingRules)
        {

            $realRequestRoutingRuleName = $requestRoutingRules[$rule.id].name

            if ($requestRoutingRules[$rule.id].properties.ruleType -eq "PathBasedRouting")
            {

                $tmpPathMap = $urlPathMaps[$requestRoutingRules[$rule.id].properties.urlPathMap.id].properties.pathRules

                foreach ($map in $tmpPathMap)
                {

                    $realPathMapPath = $map.properties.paths -join ","

                    $realPathMapBackendName = $backendAddressPools[$map.properties.backendAddressPool.id].name
                    $realPathMapHttpSettingsName = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].name
                    $realPathMapTargetName = $map.name

                    $realhttpSettingName = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].name
                    $realProtocol = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].properties.protocol
                    $realPort = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].properties.port
                    $realHttpProvisioning = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].properties.provisioningState

                    $tmpProbeID = $backendHttpSettingsCollection[$map.properties.backendHttpSettings.id].properties.probe
                    if ($tmpProbeID -ne $null) 
                    {
                        $RealProbeName = $probes[$tmpProbeID.id].Name
                        $RealProbepath = $probes[$tmpProbeID.id].properties.path
                        if (($($probes[$tmpProbeID.id].properties.match.body) -ne $null) -and ($($probes[$tmpProbeID.id].properties.match.statusCodes) -ne $null))
                        {
                            $RealProbeMatch = "Body: $($probes[$tmpProbeID.id].properties.match.body) | Status Code: $($probes[$tmpProbeID.id].properties.match.statusCodes)"
                        } else
                        {
                            $RealProbeMatch = "NA"
                        }
                        $tmpPickHostname = $probes[$tmpProbeID.id].properties.pickHostNameFromBackendHttpSettings

                        if ($tmpPickHostname) 
                        {
                            $tmpHostname = "Picked from Backend HTTP Settings"
                        } else
                        {
                            $tmpHostname = $probes[$tmpProbeID.id].properties.host
                        }
                        $tmpProtocol = $probes[$tmpProbeID.id].properties.protocol

                        if ($tmpHostname -eq $null) 
                        {
                            $tmpRoutingID = $backendHttpSettingsCollection[$tmpProbebackendID].properties.requestRoutingRules.id
                            $tmpBackendAddressPool = $requestRoutingRules[$tmpRoutingID].properties.backendAddressPool.id
                            $tmpBackendAddresses = $backendAddressPools[$tmpBackendAddressPool].properties.backendAddresses
                            $tmpHostname = $tmpBackendAddresses
                        }
                        if (($tmpHostName -ne "") -and ($tmpHostname -ne "Picked from Backend HTTP Settings"))
                        {
                            $realProbeHostname = $tmpProtocol + "://" + $tmpHostName
                        } else
                        {
                            $realProbeHostname = $tmpHostName 
                        }
                    } else
                    {
                        $RealProbeName = "NA"
                        $RealProbePath = "NA"
                        $RealProbeHostName = "NA"
                        $RealProbeMatch = "NA"
                    }

                    $RealBackendPoolName = $backendAddressPools[$map.properties.backendAddressPool.id].name
                    $tmpBackendPoolAddresses = $backendAddressPools[$map.properties.backendAddressPool.id].properties.backendAddresses

                    if ($tmpBackendPoolAddresses.ipAddress -eq $null)
                    {
                        $RealBackendPoolAddresses = $tmpBackendPoolAddresses.fqdn -join ","
                    } else
                    {
                        $RealBackendPoolAddresses = $tmpBackendPoolAddresses.ipAddress -join ","
                    }

                    $record = New-Object -TypeName psobject
                    $record | Add-Member -MemberType NoteProperty -Name GWName -value $appGWName
                    $record | Add-Member -MemberType NoteProperty -Name ResourceGroup -value $appGWRG
                    $record | Add-Member -MemberType NoteProperty -Name SubscriptionID -value $appGWSubID
                    $record | Add-Member -MemberType NoteProperty -Name ProvisionState -value $appGWProvisioningState
                    $record | Add-Member -MemberType NoteProperty -Name OperationalState -value $appGWOperationalState
                    $record | Add-Member -MemberType NoteProperty -Name SKU -value $appGWSku
                    $record | Add-Member -MemberType NoteProperty -Name Tier -value $appGWTier
                    $record | Add-Member -MemberType NoteProperty -Name Capacity -value $appGWCapacity
                    $record | Add-Member -MemberType NoteProperty -Name FrontEndIP -value $realFrontEndIP
                    $record | Add-Member -MemberType NoteProperty -Name ListenerName -value $realListenerName
                    $record | Add-Member -MemberType NoteProperty -Name RuleName -value $realRequestRoutingRuleName
                    $record | Add-Member -MemberType NoteProperty -Name HTTPSettingName -value $realhttpSettingName
                    $record | Add-Member -MemberType NoteProperty -Name Protocol -value $realProtocol
                    $record | Add-Member -MemberType NoteProperty -Name HTTPProvisioningStatus -value $realHttpProvisioning
                    $record | Add-Member -MemberType NoteProperty -Name RedirectType -value "NA"
                    $record | Add-Member -MemberType NoteProperty -Name BackendPoolName -value $RealBackendPoolName
                    $record | Add-Member -MemberType NoteProperty -Name BackendPoolAddresses -value $RealBackendPoolAddresses
                    $record | Add-Member -MemberType NoteProperty -Name Probe -value $RealProbeName
                    $record | Add-Member -MemberType NoteProperty -Name ProbeHostName -value $realProbeHostname
                    $record | Add-Member -MemberType NoteProperty -Name ProbePath -value $RealProbepath
                    $record | Add-Member -MemberType NoteProperty -Name ProbeMatch -value $RealProbeMatch
                    $record | Add-Member -MemberType NoteProperty -Name PathTargetName -value $realPathMapTargetName
                    $record | Add-Member -MemberType NoteProperty -Name Path -value $realPathMapPath
                    $record | Add-Member -MemberType NoteProperty -Name PathBackendName -value $realPathMapBackendName
                    $record | Add-Member -MemberType NoteProperty -Name PathHttpSettingsName -value $realPathMapHttpSettingsName

                    $table += $record
                }

            }

            if ($requestRoutingRules[$rule.id].properties.ruleType -eq "Basic")
            {
                if ($requestRoutingRules[$rule.id].properties.backendHttpSettings -ne $null) 
                {

                    foreach ($httpSetting in $requestRoutingRules[$rule.id].properties.backendHttpSettings)
                    {
                        if ($httpSetting.id -ne $null) 
                        {
                            if ($backendHttpSettingsCollection.contains($httpSetting.id)) 
                                {
                                    $realhttpSettingName = $backendHttpSettingsCollection[$httpSetting.id].name
                                    $realProtocol = $backendHttpSettingsCollection[$httpSetting.id].properties.protocol
                                    $realPort = $backendHttpSettingsCollection[$httpSetting.id].properties.port
                                    $realHttpProvisioning = $backendHttpSettingsCollection[$httpSetting.id].properties.provisioningState
                                    $tmpProbeID = $backendHttpSettingsCollection[$httpSetting.id].properties.probe
                                    if ($tmpProbeID -ne $null) 
                                    {
                                        $RealProbeName = $probes[$tmpProbeID.id].Name
                                        $RealProbepath = $probes[$tmpProbeID.id].properties.path
                                        if (($($probes[$tmpProbeID.id].properties.match.body) -ne $null) -and ($($probes[$tmpProbeID.id].properties.match.statusCodes) -ne $null))
                                        {
                                            $RealProbeMatch = "Body: $($probes[$tmpProbeID.id].properties.match.body) | Status Code: $($probes[$tmpProbeID.id].properties.match.statusCodes)"
                                        } else
                                        {
                                            $RealProbeMatch = "NA"
                                        }

                                                    
                                        $tmpPickHostname = $probes[$tmpProbeID.id].properties.pickHostNameFromBackendHttpSettings

                                        if ($tmpPickHostname)
                                        {
                                            $tmpHostname = "Picked from Backend HTTP Settings"
                                        } else
                                        {
                                            $tmpHostname = $probes[$tmpProbeID.id].properties.host
                                        }

                                        $tmpProtocol = $probes[$tmpProbeID.id].properties.protocol
                                                
                                        if ($tmpHostname -eq $null)
                                        {
                                            $tmpRoutingID = $backendHttpSettingsCollection[$tmpProbebackendID].properties.requestRoutingRules.id
                                            $tmpBackendAddressPool = $requestRoutingRules[$tmpRoutingID].properties.backendAddressPool.id
                                            $tmpBackendAddresses = $backendAddressPools[$tmpBackendAddressPool].properties.backendAddresses
                                            $tmpHostname = $tmpBackendAddresses
                                        }
                                        if (($tmpHostName -ne "") -and ($tmpHostname -ne "Picked from Backend HTTP Settings"))
                                        {
                                            $realProbeHostname = $tmpProtocol + "://" + $tmpHostName
                                        } else
                                        {
                                            $realProbeHostname = $tmpHostName
                                        }
                                    } else
                                    {
                                        $RealProbeName = "NA"
                                        $RealProbePath = "NA"
                                        $RealProbeHostName = "NA"
                                        $RealProbeMatch = "NA"
                                    }
                                } else
                                {
                                    $realhttpSettingName = "None - $($httpSetting.id)"
                                    $realProtocol = "None"
                                    $realPort = "None"
                                    $realHttpProvisioning = "None"
                                }
                            }
                        }

                        foreach ($backendPool in $requestRoutingRules[$rule.id].properties.backendAddressPool)
                        {
                            $backendPoolID = $backendPool.id
                            $RealBackendPoolName = $backendAddressPools[$backendPoolID].name
                            $tmpBackendPoolAddresses = $backendAddressPools[$backendPoolID].properties.backendAddresses

                            if ($tmpBackendPoolAddresses.ipAddress -eq $null)
                            {
                                $RealBackendPoolAddresses = $tmpBackendPoolAddresses.fqdn -join ","
                            } else
                            {
                                $RealBackendPoolAddresses = $tmpBackendPoolAddresses.ipAddress -join ","
                            }


                            $record = New-Object -TypeName psobject
                            $record | Add-Member -MemberType NoteProperty -Name GWName -value $appGWName
                            $record | Add-Member -MemberType NoteProperty -Name ResourceGroup -value $appGWRG
                            $record | Add-Member -MemberType NoteProperty -Name SubscriptionID -value $appGWSubID
                            $record | Add-Member -MemberType NoteProperty -Name ProvisionState -value $appGWProvisioningState
                            $record | Add-Member -MemberType NoteProperty -Name OperationalState -value $appGWOperationalState
                            $record | Add-Member -MemberType NoteProperty -Name SKU -value $appGWSku
                            $record | Add-Member -MemberType NoteProperty -Name Tier -value $appGWTier
                            $record | Add-Member -MemberType NoteProperty -Name Capacity -value $appGWCapacity
                            $record | Add-Member -MemberType NoteProperty -Name FrontEndIP -value $realFrontEndIP
                            $record | Add-Member -MemberType NoteProperty -Name ListenerName -value $realListenerName
                            $record | Add-Member -MemberType NoteProperty -Name RuleName -value $realRequestRoutingRuleName
                            $record | Add-Member -MemberType NoteProperty -Name HTTPSettingName -value $realhttpSettingName
                            $record | Add-Member -MemberType NoteProperty -Name Protocol -value $realProtocol
                            $record | Add-Member -MemberType NoteProperty -Name HTTPProvisioningStatus -value $realHttpProvisioning
                            $record | Add-Member -MemberType NoteProperty -Name RedirectType -value "NA"
                            $record | Add-Member -MemberType NoteProperty -Name BackendPoolName -value $RealBackendPoolName
                            $record | Add-Member -MemberType NoteProperty -Name BackendPoolAddresses -value $RealBackendPoolAddresses
                            $record | Add-Member -MemberType NoteProperty -Name Probe -value $RealProbeName
                            $record | Add-Member -MemberType NoteProperty -Name ProbeHostName -value $realProbeHostname
                            $record | Add-Member -MemberType NoteProperty -Name ProbePath -value $RealProbepath
                            $record | Add-Member -MemberType NoteProperty -Name ProbeMatch -value $RealProbeMatch
                            $record | Add-Member -MemberType NoteProperty -Name PathTargetName -value ""
                            $record | Add-Member -MemberType NoteProperty -Name Path -value ""
                            $record | Add-Member -MemberType NoteProperty -Name PathBackendName -value ""
                            $record | Add-Member -MemberType NoteProperty -Name PathHttpSettingsName -value ""

                            $table += $record
                        }

                } else
                {
 
                    foreach ($redirectSetting in $requestRoutingRules[$rule.id].properties.redirectConfiguration)
                    {
                        $parsedRuleID = $rule.id.split("/")[10]
                        if ($redirectConfigurations.values | select-string -pattern $parsedRuleID) 
                        {
                            foreach ($tmpRuleID in $redirectConfigurations)
                            {
                                foreach ($tmpkey in $tmpRuleID.Keys)
                                {
                                    if ($tmpkey -match $parsedRuleID)
                                    {
                                        $realRedirectType = $redirectConfigurations[$tmpkey].properties.redirectType
                                    }
                                }

                            }

                        } else
                        {
                            $realRedirectType = "NA"
                        }

                        $record = New-Object -TypeName psobject
                        $record | Add-Member -MemberType NoteProperty -Name GWName -value $appGWName
                        $record | Add-Member -MemberType NoteProperty -Name ResourceGroup -value $appGWRG
                        $record | Add-Member -MemberType NoteProperty -Name SubscriptionID -value $appGWSubID
                        $record | Add-Member -MemberType NoteProperty -Name ProvisionState -value $appGWProvisioningState
                        $record | Add-Member -MemberType NoteProperty -Name OperationalState -value $appGWOperationalState
                        $record | Add-Member -MemberType NoteProperty -Name SKU -value $appGWSku
                        $record | Add-Member -MemberType NoteProperty -Name Tier -value $appGWTier
                        $record | Add-Member -MemberType NoteProperty -Name Capacity -value $appGWCapacity
                        $record | Add-Member -MemberType NoteProperty -Name FrontEndIP -value $realFrontEndIP
                        $record | Add-Member -MemberType NoteProperty -Name ListenerName -value $realListenerName
                        $record | Add-Member -MemberType NoteProperty -Name RuleName -value $realRequestRoutingRuleName
                        $record | Add-Member -MemberType NoteProperty -Name HTTPSettingName -value "NA"
                        $record | Add-Member -MemberType NoteProperty -Name Protocol -value "NA"
                        $record | Add-Member -MemberType NoteProperty -Name HTTPProvisioningStatus -value "NA"
                        $record | Add-Member -MemberType NoteProperty -Name RedirectType -value $realRedirectType
                        $record | Add-Member -MemberType NoteProperty -Name BackendPoolName -value ""
                        $record | Add-Member -MemberType NoteProperty -Name BackendPoolAddresses -value ""
                        $record | Add-Member -MemberType NoteProperty -Name Probe -value ""
                        $record | Add-Member -MemberType NoteProperty -Name ProbeHostName -value ""
                        $record | Add-Member -MemberType NoteProperty -Name ProbePath -value ""
                        $record | Add-Member -MemberType NoteProperty -Name ProbeMatch -value ""
                        $record | Add-Member -MemberType NoteProperty -Name PathTargetName -value ""
                        $record | Add-Member -MemberType NoteProperty -Name Path -value ""
                        $record | Add-Member -MemberType NoteProperty -Name PathBackendName -value ""
                        $record | Add-Member -MemberType NoteProperty -Name PathHttpSettingsName -value ""

                        $table += $record

                    }
                }
            }
        }
    }
}


$table | select-object GWName, ResourceGroup, SubscriptionID, ProvisionState, OperationalState, SKU, Tier, Capacity, FrontEndIP, ListenerName, RuleName, PathTargetName, Path, PathBackendName, PathHttpSettingsName, HTTPSettingName, Protocol, HTTPProvisioningStatus, RedirectType, BackendPoolName, BackendPoolAddresses, Probe, ProbeHostName, ProbePath, ProbeMatch | export-Csv -path $outputPath -NoTypeInformation
invoke-item $outputPath