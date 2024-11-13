$DashboardName = "<<name of dashboard>>"
$ListOfResources = "<<List of resource IDs>>"
$outputFolder = "<<output folder>>"

if ($PSVersionTable.PSVersion -lt [version]"7.0") 
{
    write-host -ForegroundColor red "This script needs Powershell 7 or higher to run"
    exit
}

if (!($ListOfResources -is [array])) {
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
        [string] $_ResourceID,
        [string] $_MetricName,
        [string] $_subTitle,
        [boolean] $_ByLUN
    )
    $tileobj = ""

    $resourceName = $_resourceId.split("/")[-1]

    $Namespace = "$($_resourceId.split('/')[6])/$($_resourceId.split('/')[7])"

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
                                    "top": 50
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
                            }
                            }
                        }
                        }
                    }
                    }
                }
            }
"@ }
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
    write-host $ResourceID
    $ResourceName = $ResourceID.split("/")[8]
    write-host $ResourceName


    $value = build-tile -_id $id -_x 0 -_y $y -_type "Extension/HubsExtension/PartType/MarkdownPart" -_ResourceID $ResourceID -_subTitle "Server Metrics"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $id -Value $value.$id

    $value = build-tile -_id $($id+1) -_x 0 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "VM Uncached Bandwidth Consumed Percentage"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+1) -Value $value.$($id+1)

    $value = build-tile -_id $($id+2) -_x 5 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "VM Uncached IOPS Consumed Percentage"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+2) -Value $value.$($id+2)

    $value = build-tile -_id $($id+3) -_x 10 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Network In Total"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+3) -Value $value.$($id+3)

    $value = build-tile -_id $($id+4) -_x 15 -_y $($y+1) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Network Out Total" 
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+4) -Value $value.$($id+4)

    $value = build-tile -_id $($id+5) -_x 0 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "Percentage CPU"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+5) -Value $value.$($id+5)

    $value = build-tile -_id $($id+6) -_x 5 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk Bandwidth Consumed Percentage"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+6) -Value $value.$($id+6)

    $value = build-tile -_id $($id+7) -_x 10 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk IOPS Consumed Percentage"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+7) -Value $value.$($id+7)

    $value = build-tile -_id $($id+8) -_x 15 -_y $($y+5) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ResourceID $ResourceID -_MetricName "OS Disk Latency"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+8) -Value $value.$($id+8)

    $value = build-tile -_id $($id+9) -_x 0 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Read Operations/Sec"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+9) -Value $value.$($id+9)

    $value = build-tile -_id $($id+10) -_x 5 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Write Operations/Sec"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+10) -Value $value.$($id+10)

    $value = build-tile -_id $($id+11) -_x 10 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Latency"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+11) -Value $value.$($id+11)

    $value = build-tile -_id $($id+12) -_x 15 -_y $($y+9) -_type "Extension/HubsExtension/PartType/MonitorChartPart" -_ByLUN $true -_ResourceID $ResourceID -_MetricName "Data Disk Queue Depth"
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+12) -Value $value.$($id+12)

    $y += 13
    $id += 13
    $counter += 1

    if ($counter -gt 10) 
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

  #if ($starter.properties.lenses."0".parts."0".count -gt 0)
  #{
    $starter.name = "$DashboardName-$filenameCount"
    $starter.tags.'hidden-title' = "$DashboardName-$filenameCount"
    $outFilePath = "$outputfolder\$DashboardName-$filenameCount.json"
    Write-host -ForegroundColor yellow "Outputing to $outFilePath"
    $starter | ConvertTo-Json -depth 100 | Out-File $outFilePath
  #}
}
