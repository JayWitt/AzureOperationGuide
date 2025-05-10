$DashboardName = "<<name of dashboard>>"
$ListOfResources = '<<List of resource IDs>>' #Put in single quotes or in an array with section name as the first value. See docs for more details.
$outputFolder = "<<output folder>>"
$_region = "<<Region>>"

if ($PSVersionTable.PSVersion -lt [version]"7.0") 
{
    write-host -ForegroundColor red "This script needs Powershell 7 or higher to run"
    exit
}

if ((!($ListOfResources -is [array])) -and $listofResources.count -ne 1) {
  write-host -ForegroundColor Red "Please check the ListOfResources variable to make sure it is an array of Resource IDs (Could be single or double quotes)"
  write-host -ForegroundColor Red ""
  write-host -ForegroundColor Red "SYNTAX: ""/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/xxxxxxxxx/providers/Microsoft.Compute/virtualMachines/xxxxxxx"",""/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/xxxxxxxxx/providers/Microsoft.Compute/virtualMachines/yyyyyyyy"""
  exit
}


$mainstarter = @"
{
    "properties": {
      "lenses": {
        "0": {
          "order": 0,
          "parts": {
          }
        }
      },
      "metadata": {
        "model": {
          "timeRange": {
            "value": {
              "relative": {
                "duration": 24,
                "timeUnit": 1
              }
            },
            "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
          },
          "filterLocale": {
            "value": "en-us"
          },
          "filters": {
            "value": {
              "MsPortalFx_TimeRange": {
                "model": {
                  "format": "utc",
                  "granularity": "1m",
                  "relative": "24h"
                },
                "displayCache": {
                  "name": "UTC Time",
                  "value": "Past 24 hours"
                },
                "filteredPartIds": []
              }
            }
          }
        }
      }
    },
    "name": "$DashboardName",
    "type": "Microsoft.Portal/dashboards",
    "location": "INSERT LOCATION",
    "tags": {
      "hidden-title": "$DashboardName"
    },
    "apiVersion": "2015-08-01-preview"
  }
"@


function Build-Tile {
    param (
        [Parameter(Mandatory=$true)]
        [int] $_id,
        [Parameter(Mandatory=$true)]
        [int] $_x,
        [Parameter(Mandatory=$true)]
        [int] $_y,
        [Parameter(Mandatory=$true)]
        [string] $_type,
        [Parameter(Mandatory=$true)]
        $_ResourceID,
        [string] $_MetricName,
        [string] $_subTitle,
        [boolean] $_ByLUN
    )
    $tileobj = ""
    $Filters = ""

    if ($_ResourceID -is [Array])
    {
        if ($_ResourceId.Count -gt 11) {write-host -ForegroundColor Red "WARNING -- $($_ResourceId.Count) resources found. Maximum number of 10 resources can be viewed at a time. Consider reducing the number."}


        foreach ($entry in $_ResourceID)
        {
            if ($entry.substring(0,1) -ne "/")
            {
                $ResourceName = $entry
                if ($GroupName -eq "") {
                    $GroupName = $entry
                }

            } else
            {
                $Namespace = "$($entry.split('/')[6])/$($entry.split('/')[7])"
                $subscriptionID = "$($entry.split('/')[2])"
                $multipleResourceIDs += """$entry"","
            }
        }

        if ($multipleResourceIDs -ne "") {$multipleResourceIDs.substring(0,$multipleResourceIDs.Length-1)}

        if (($_type -ne "Extension/HubsExtension/PartType/MarkdownPart") -and ($_MetricName -notin ("VM Uncached Bandwidth Consumed Percentage","VM Uncached IOPS Consumed Percentage","Percentage CPU","OS Disk Bandwidth Consumed Percentage","OS Disk IOPS Consumed Percentage","OS Disk Latency","Totaliops","TotalThroughput","Throughputlimitreached","ReadThroughput","WriteThroughput","AverageReadLatency","AverageWriteLatency","BitsInPerSecond","BitsOutPerSecond","EgressBandwidthUtilization","IngressBandwidthUtilization"))) 
        {
            write-host -ForegroundColor Red "Metric is not capable of supporting multiple resources. Skipping $_MetricName"
            return "ERROR"
            #break
        }

        $Filters = @"
    ,
                    "filterCollection": {
                    "filters": [
                        {
                        "key": "Microsoft.ResourceId",
                        "operator": 0,
                        "values": [$multipleResourceIDs
                        ]
                        }
                    ]
                    },
                    "grouping": {
                    "dimension": "Microsoft.ResourceId"
                    }
"@
    } else {
        #$GroupName = ""
        #if ($GroupName -eq "") {
            $resourceName = $_resourceId.split("/")[-1]
        #}

      $Namespace = "$($_resourceId.split('/')[6])/$($_resourceId.split('/')[7])"
      $subscriptionID = "$($_resourceId.split('/')[2])"
    }

    $DisplayName = "Subscription($($SubscriptionID.Substring(0,4)))"


    switch ($_type)
    {
        "Extension/HubsExtension/PartType/MarkdownPart" { 
            $tileObj = @"
            {
            "$id": {
              "position": {
                "x": 0,
                "y": $_y,
                "colSpan": 20,
                "rowSpan": 1
              },
              "metadata": {
                "inputs": [],
                "type": "Extension/HubsExtension/PartType/MarkdownPart",
                "settings": {
                  "content": {
                    "content": "",
                    "title": "$ResourceName",
                    "subtitle": "$_subTitle",
                    "markdownSource": 1,
                    "markdownUri": ""
                  }
                },
                "partHeader": {
                  "title": "$ResourceName",
                  "subtitle": "$_subTitle"
                }
              }
            }
          }
"@ }

        "Extension/HubsExtension/PartType/MonitorChartPart" {

            if ($Namespace -eq "microsoft.compute/virtualmachines")
            {
                if ($_ResourceID -is [array])
                {
                  $resourceMetadata =@"
                            "region": "$_region",
                            "resourceType": "microsoft.compute/virtualmachines",
                            "subscription": {
                              "subscriptionId": "$subscriptionID",
                              "displayName": "$DisplayName",
                              "uniqueDisplayName": "$DisplayName"
                            }
"@
                } else {
                  $resourceMetadata =@"
                    "id": "$_ResourceID"
"@
                }

                if ($_ByLUN)
                {
                    $tileObj = @"
                    {
                    "$($_id)": {
                        "position": {
                        "x": $_x,
                        "y": $_y,
                        "colSpan": 5,
                        "rowSpan": 4
                        },
                        "metadata": {
                        "inputs": [
                            {
                            "name": "sharedTimeRange",
                            "isOptional": true
                            },
                            {
                            "name": "options",
                            "value": {
                                "chart": {
                                "metrics": [
                                    {
                                    "resourceMetadata": {
                                        "id": "$_ResourceID"
                                    },
                                    "name": "$_metricName",
                                    "aggregationType": 4,
                                    "namespace": "$namespace",
                                    "metricVisualization": {
                                        "displayName": "$_metricName"
                                    }
                                    }
                                ],
                                "title": "[$ResourceName] $_metricName by LUN",
                                "titleKind": 1,
                                "visualization": {
                                    "chartType": 2,
                                    "legendVisualization": {
                                    "isVisible": true,
                                    "position": 2,
                                    "hideHoverCard": false,
                                    "hideLabelNames": false
                                    },
                                    "axisVisualization": {
                                    "x": {
                                        "isVisible": true,
                                        "axisType": 2
                                    },
                                    "y": {
                                        "isVisible": true,
                                        "axisType": 1
                                    }
                                    }
                                },
                                "timespan": {
                                    "relative": {
                                    "duration": 604800000
                                    },
                                    "showUTCTime": false,
                                    "grain": 1
                                }
                                }
                            },
                            "isOptional": true
                            }
                        ],
                        "type": "$_type",
                        "settings": {
                            "content": {
                            "options": {
                                "chart": {
                                "metrics": [
                                    {
                                    "resourceMetadata": {
                                        "id": "$_ResourceID"
                                    },
                                    "name": "$_metricName",
                                    "aggregationType": 4,
                                    "namespace": "$namespace",
                                    "metricVisualization": {
                                        "displayName": "$_metricName"
                                    }
                                    }
                                ],
                                "title": "[$ResourceName] $_metricName by LUN",
                                "titleKind": 1,
                                "visualization": {
                                    "chartType": 2,
                                    "legendVisualization": {
                                    "isVisible": true,
                                    "position": 2,
                                    "hideHoverCard": false,
                                    "hideLabelNames": false
                                    },
                                    "axisVisualization": {
                                    "x": {
                                        "isVisible": true,
                                        "axisType": 2
                                    },
                                    "y": {
                                        "isVisible": true,
                                        "axisType": 1
                                    }
                                    },
                                    "disablePinning": true
                                },
                                "grouping": {
                                    "dimension": "LUN",
                                    "sort": 2,
                                    "top": 64
                                }
                                }
                            }
                            }
                        }
                        }
                    }
                    }
"@ 
                } else {
                $tileObj = @"
                {
                "$($_id)": {
                    "position": {
                    "x": $_x,
                    "y": $_y,
                    "colSpan": 5,
                    "rowSpan": 4
                    },
                    "metadata": {
                    "inputs": [
                        {
                        "name": "sharedTimeRange",
                        "isOptional": true
                        },
                        {
                        "name": "options",
                        "value": {
                            "chart": {
                            "metrics": [
                                {
                                "resourceMetadata": {
                                    $resourceMetadata
                                },
                                "name": "$_metricName",
                                "aggregationType": 4,
                                "namespace": "$namespace",
                                "metricVisualization": {
                                    "displayName": "$_metricName"
                                }
                                }
                            ],
                            "title": "[$ResourceName] $_metricName",
                            "titleKind": 1,
                            "visualization": {
                                "chartType": 2,
                                "legendVisualization": {
                                "isVisible": true,
                                "position": 2,
                                "hideHoverCard": false,
                                "hideLabelNames": false
                                },
                                "axisVisualization": {
                                "x": {
                                    "isVisible": true,
                                    "axisType": 2
                                },
                                "y": {
                                    "isVisible": true,
                                    "axisType": 1
                                }
                                }
                            },
                            "timespan": {
                                "relative": {
                                "duration": 604800000
                                },
                                "showUTCTime": false,
                                "grain": 1
                            }
                            }
                        },
                        "isOptional": true
                        }
                    ],
                    "type": "$_type",
                    "settings": {
                        "content": {
                        "options": {
                            "chart": {
                            "metrics": [
                                {
                                "resourceMetadata": {
                                    $resourceMetadata
                                },
                                "name": "$_metricName",
                                "aggregationType": 4,
                                "namespace": "$namespace",
                                "metricVisualization": {
                                    "displayName": "$_metricName"
                                }
                                }
                            ],
                            "title": "[$ResourceName] $_metricName",
                            "titleKind": 1,
                            "visualization": {
                                "chartType": 2,
                                "legendVisualization": {
                                "isVisible": true,
                                "position": 2,
                                "hideHoverCard": false,
                                "hideLabelNames": false
                                },
                                "axisVisualization": {
                                "x": {
                                    "isVisible": true,
                                    "axisType": 2
                                },
                                "y": {
                                    "isVisible": true,
                                    "axisType": 1
                                }
                                },
                                "disablePinning": true
                            }$Filters
                            }
                        }
                        }
                    }
                    }
                }
            }
"@ }
            } elseif ($Namespace -eq "microsoft.netapp/netappaccounts")
            {
                if ($_ResourceID -is [array])
                {
                  $resourceMetadata =@"
                            "region": "$_region",
                            "resourceType": "microsoft.netapp/netappaccounts/capacitypools/volumes",
                            "subscription": {
                              "subscriptionId": "$subscriptionID",
                              "displayName": "$DisplayName",
                              "uniqueDisplayName": "$DisplayName"
                            }
"@
                } else {
                  $resourceMetadata =@"
                    "id": "$_ResourceID"
"@
                }

                $tileObj = @"
                {
                "$($_id)": {
                    "position": {
                    "x": $_x,
                    "y": $_y,
                    "colSpan": 5,
                    "rowSpan": 4
                    },
                    "metadata": {
                    "inputs": [
                        {
                        "name": "sharedTimeRange",
                        "isOptional": true
                        },
                        {
                        "name": "options",
                        "value": {
                            "chart": {
                            "metrics": [
                                {
                                "resourceMetadata": {
                                    $resourceMetadata
                                },
                                "name": "$_metricName",
                                "aggregationType": 4,
                                "namespace": "microsoft.netapp/netappaccounts/capacitypools/volumes",
                                "metricVisualization": {
                                    "displayName": "$_metricName"
                                }
                                }
                            ],
                            "title": "[$ResourceName] $_metricName",
                            "titleKind": 1,
                            "visualization": {
                                "chartType": 2,
                                "legendVisualization": {
                                "isVisible": true,
                                "position": 2,
                                "hideHoverCard": false,
                                "hideLabelNames": false
                                },
                                "axisVisualization": {
                                "x": {
                                    "isVisible": true,
                                    "axisType": 2
                                },
                                "y": {
                                    "isVisible": true,
                                    "axisType": 1
                                }
                                }
                            }$Filters,
                            "timespan": {
                                "relative": {
                                "duration": 604800000
                                },
                                "showUTCTime": false,
                                "grain": 1
                            }
                            }
                        },
                        "isOptional": true
                        }
                    ],
                    "type": "$_type",
                    "settings": {
                        "content": {
                        "options": {
                            "chart": {
                            "metrics": [
                                {
                                "resourceMetadata": {
                                    $resourceMetadata
                                },
                                "name": "$_metricName",
                                "aggregationType": 4,
                                "namespace": "microsoft.netapp/netappaccounts/capacitypools/volumes",
                                "metricVisualization": {
                                    "displayName": "$_metricName",
                                    "resourceDisplayName": "$DisplayName"
                                }
                                }
                            ],
                            "title": "[$ResourceName] $_metricName",
                            "titleKind": 1,
                            "visualization": {
                                "chartType": 2,
                                "legendVisualization": {
                                "isVisible": true,
                                "position": 2,
                                "hideHoverCard": false,
                                "hideLabelNames": false
                                },
                                "axisVisualization": {
                                "x": {
                                    "isVisible": true,
                                    "axisType": 2
                                },
                                "y": {
                                    "isVisible": true,
                                    "axisType": 1
                                }
                                },
                                "disablePinning": true
                            }$Filters,
                            "grouping": {
                                "dimension": "Microsoft.ResourceId"
                            }
                            }
                        }
                        }
                    }
                    }
                }
                }
"@ 

            } elseif ($Namespace -eq "microsoft.network/expressroutecircuits")
            {

                if ($_ResourceID -is [array])
                {
                    write-host -ForegroundColor Red "Error! Can't group ExpressRoute circuits."
                    break
                } 

                $tileObj = @"
                {
                "$($_id)": {
            "position": {
                    "x": $_x,
                    "y": $_y,
              "colSpan": 5,
              "rowSpan": 4
            },
            "metadata": {
              "inputs": [
                {
                  "name": "options",
                  "isOptional": true
                },
                {
                  "name": "sharedTimeRange",
                  "isOptional": true
                }
              ],
              "type": "Extension/HubsExtension/PartType/MonitorChartPart",
              "settings": {
                "content": {
                  "options": {
                    "chart": {
                      "metrics": [
                        {
                          "resourceMetadata": {
                            "id": "$_ResourceID"
                          },
                          "name": "$_metricName",
                          "aggregationType": 4,
                          "namespace": "microsoft.network/expressroutecircuits",
                          "metricVisualization": {
                            "displayName": "$_metricName",
                            "resourceDisplayName": "$DisplayName"
                          }
                        }
                      ],
                      "title": "[$ResourceName] $_metricName",
                      "titleKind": 1,
                      "visualization": {
                        "chartType": 2,
                        "legendVisualization": {
                          "isVisible": true,
                          "position": 2,
                          "hideHoverCard": false,
                          "hideLabelNames": true
                        },
                        "axisVisualization": {
                          "x": {
                            "isVisible": true,
                            "axisType": 2
                          },
                          "y": {
                            "isVisible": true,
                            "axisType": 1
                          }
                        },
                        "disablePinning": true
                      }
                    }
                  }
                }
              }
            }
          }
                }
"@ 
            } elseif ($Namespace -eq "")
            {
                $tileObj = "{}"
            }

        }

        default{
            $tileObj = "{}"
        }

    }

    $tileobj = $tileobj | ConvertFrom-Json
    return $tileobj 

}
  

$starter = $mainstarter | convertFrom-json
$counter = 1
$filenameCount = 1

$id=0
$y = 0
foreach ($ResourceID in $ListOfResources)
{
    $resourceName = ""
    $value = build-tile -_id $id -_x 0 -_y $y -_type "Extension/HubsExtension/PartType/MarkdownPart" -_ResourceID $ResourceID -_subTitle "Metrics"
    if ($value -ne "") {
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
        $id += 1 
    }
    
    if ($ResourceID -is [array]) 
    {

        $ResourceType = "$($resourceId[1].split('/')[6])/$($resourceId[1].split('/')[7])"   
        
    } else {
        $ResourceType = "$($resourceId.split('/')[6])/$($resourceId.split('/')[7])"
    }

    if ($ResourceType -eq "microsoft.compute/virtualmachines")
    {
        $UseRow2 = 0
        $UseRow3 = 0
        $UseRow4 = 0

        $value = build-tile -_id $($id) -_x 0 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "VM Uncached Bandwidth Consumed Percentage"
        
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 5 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "VM Uncached IOPS Consumed Percentage"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 10 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Network In Total"
        if ($value -notcontains "ERROR") {

            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 15 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Network Out Total" 
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 0 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Percentage CPU"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $UseRow2 = 4
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 5 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk Bandwidth Consumed Percentage"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $UseRow2 = 4
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 10 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk IOPS Consumed Percentage"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $UseRow2 = 4
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 15 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk Latency"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $UseRow2 = 4
            $id += 1 
        }

    
        if ($_ResourceID -isnot [array]){
            $value = build-tile -_id $($id) -_x 0 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Read Operations/Sec"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow3 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 5 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Write Operations/Sec"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow3 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 10 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Read Bytes/Sec"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow3 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 15 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Write Bytes/Sec"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow3 = 4
                $id += 1 
            }

            $value = build-tile -_id $($id) -_x 0 -_y $($y+13) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Bandwidth Consumed Percentage"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow4 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 5 -_y $($y+13) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk IOPS Consumed Percentage"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow4 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 10 -_y $($y+13) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Latency"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow4 = 4
                $id += 1 
            }
        
            $value = build-tile -_id $($id) -_x 15 -_y $($y+13) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Queue Depth"
            if ($value -notcontains "ERROR") {
                $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
                $useRow4 = 4
                $id += 1 
            }

            $y = $y + $UseRow2 + $UseRow3 + $UseRow4 + 4 + 1
        } else {
            $y += 9
        }
    
        $counter += 1   
    }

    if ($ResourceType -eq "microsoft.netapp/netappaccounts")
    {
        $value = build-tile -_id $($id) -_x 0 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Totaliops"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 5 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "TotalThroughput"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 10 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Throughputlimitreached"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $value = build-tile -_id $($id) -_x 0 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "ReadThroughput"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $value = build-tile -_id $($id) -_x 5 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "WriteThroughput"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $value = build-tile -_id $($id) -_x 10 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "AverageReadLatency"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $value = build-tile -_id $($id) -_x 15 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "AverageWriteLatency"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }


        $y += 9
        #$id += 5
        $counter += 1   
    }

    if ($ResourceType -eq "microsoft.network/expressroutecircuits")
    {
        $value = build-tile -_id $($id) -_x 0 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "BitsInPerSecond"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 5 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "BitsOutPerSecond"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }
    
        $value = build-tile -_id $($id) -_x 10 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "EgressBandwidthUtilization"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $value = build-tile -_id $($id) -_x 15 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "IngressBandwidthUtilization"
        if ($value -notcontains "ERROR") {
            $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id) -Value $value.$($id)
            $id += 1 
        }

        $y += 5
        #$id += 5
        $counter += 1   
    }



    if ($counter -gt 13) 
    {
      $starter.name = "$DashboardName-$filenameCount"
      $starter.tags.'hidden-title' = "$DashboardName-$filenameCount"
      $outFilePath = "$outputfolder\$DashboardName-$filenameCount.json"
      Write-host -ForegroundColor yellow "Outputing to $outFilePath"
      $starter | ConvertTo-Json -depth 100 | Out-File $outFilePath
      $counter = 1
      $filenameCount += 1
      $starter = $mainstarter | convertFrom-json
      $y=0
    }

}

if ($filenameCount -eq 1)
{
  $outFilePath = "$outputfolder\$DashboardName.json"
  Write-host -ForegroundColor yellow "Outputing to $outFilePath"
  $starter | ConvertTo-Json -depth 100 | Out-File $outFilePath
} else {

    $starter.name = "$DashboardName-$filenameCount"
    $starter.tags.'hidden-title' = "$DashboardName-$filenameCount"
    $outFilePath = "$outputfolder\$DashboardName-$filenameCount.json"
    Write-host -ForegroundColor yellow "Outputing to $outFilePath"
    $starter | ConvertTo-Json -depth 100 | Out-File $outFilePath
  #}
}
