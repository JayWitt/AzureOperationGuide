$DashboardName = "<<name of dashboard>>"
$ListOfResources = "<<List of resource IDs>>"
$outputFolder = "<<output folder>>"

#####
# Resource Graph Query
#
# resources
#| where type == "microsoft.compute/virtualmachines"
#| where resourceGroup contains "<<group1>>"
#| summarize result = strcat_array(make_list(id), ",")
#
#####

$starter = @"
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
                  "granularity": "auto",
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

$starter = $starter | convertFrom-json
$counter = 1
$filenameCount = 0

$id=0
$y = 0
foreach ($ResourceID in $ListOfResources)
{
    write-host $ResourceID
    $ResourceName = $ResourceID.split("/")[8]
    write-host $ResourceName

    $value = @"
    {
    "$id": {
      "position": {
        "x": 0,
        "y": $y,
        "colSpan": 20,
        "rowSpan": 1
      },
      "metadata": {
        "inputs": [],
        "type": "Extension/HubsExtension/PartType/MarkdownPart",
        "settings": {
          "content": {
            "content": "",
            "title": "My title",
            "subtitle": "My subtitle",
            "markdownSource": 1,
            "markdownUri": ""
          }
        },
        "partHeader": {
          "title": "$ResourceName",
          "subtitle": "$purpose"
        }
      }
    }
  }
"@ | convertfrom-json
$starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $id -Value $value.$id

    $value = @"
    {
    "$($id+1)": {
        "position": {
        "x": 0,
        "y": $($y+1),
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
                        "id": "$ResourceID"
                    },
                    "name": "VM Uncached Bandwidth Consumed Percentage",
                    "aggregationType": 4,
                    "namespace": "microsoft.compute/virtualmachines",
                    "metricVisualization": {
                        "displayName": "VM Uncached Bandwidth Consumed Percentage"
                    }
                    }
                ],
                "title": "Avg VM Uncached Bandwidth Consumed Percentage for $ResourceName",
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
        "type": "Extension/HubsExtension/PartType/MonitorChartPart",
        "settings": {
            "content": {
            "options": {
                "chart": {
                "metrics": [
                    {
                    "resourceMetadata": {
                        "id": "$ResourceID"
                    },
                    "name": "VM Uncached Bandwidth Consumed Percentage",
                    "aggregationType": 4,
                    "namespace": "microsoft.compute/virtualmachines",
                    "metricVisualization": {
                        "displayName": "VM Uncached Bandwidth Consumed Percentage"
                    }
                    }
                ],
                "title": "Avg VM Uncached Bandwidth Consumed Percentage for $ResourceName",
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
"@ | convertfrom-json
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+1) -Value $value.$($id+1)

    $value = @"
    {
        "$($id+2)": {
            "position": {
            "x": 5,
            "y": $($y+1),
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
                            "id": "$ResourceID"
                        },
                        "name": "VM Uncached IOPS Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "VM Uncached IOPS Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg VM Uncached IOPS Consumed Percentage for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "VM Uncached IOPS Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "VM Uncached IOPS Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg VM Uncached IOPS Consumed Percentage for $ResourceName",
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
"@ | convertfrom-json
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+2) -Value $value.$($id+2)


    $value = @"
    {
        "$($id+3)": {
            "position": {
            "x": 10,
            "y": $($y+1),
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
                            "id": "$ResourceID"
                        },
                        "name": "Data Disk Latency",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Data Disk Latency (Preview)"
                        }
                        }
                    ],
                    "title": "Avg Data Disk Latency (Preview) for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "Data Disk Latency",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Data Disk Latency (Preview)"
                        }
                        }
                    ],
                    "title": "Avg Data Disk Latency (Preview) for $ResourceName",
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
"@ | convertfrom-json
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+3) -Value $value.$($id+3)
        
    $value = @"
    {
        "$($id+4)": {
            "position": {
            "x": 15,
            "y": $($y+1),
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
                            "id": "$ResourceID"
                        },
                        "name": "Data Disk Queue Depth",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Data Disk Queue Depth"
                        }
                        }
                    ],
                    "title": "Avg Data Disk Queue Depth for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "Data Disk Queue Depth",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Data Disk Queue Depth"
                        }
                        }
                    ],
                    "title": "Avg Data Disk Queue Depth for $ResourceName",
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
"@ | convertfrom-json
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+4) -Value $value.$($id+4)

    $value =@"
    {
        "$($id+5)": {
            "position": {
            "x": 0,
            "y": $($y+5),
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
                            "id": "$ResourceID"
                        },
                        "name": "Percentage CPU",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Percentage CPU"
                        }
                        }
                    ],
                    "title": "Avg Percentage CPU for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "Percentage CPU",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "Percentage CPU"
                        }
                        }
                    ],
                    "title": "Avg Percentage CPU for $ResourceName",
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
"@ | convertfrom-json
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+5) -Value $value.$($id+5)
        
    $value=@"
    {
        "$($id+6)": {
            "position": {
            "x": 5,
            "y": $($y+5),
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
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk Bandwidth Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk Bandwidth Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg OS Disk Bandwidth Consumed Percentage for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk Bandwidth Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk Bandwidth Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg OS Disk Bandwidth Consumed Percentage for $ResourceName",
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
"@ | convertfrom-json
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+6) -Value $value.$($id+6)

    $value=@"
    {
        "$($id+7)": {
            "position": {
            "x": 10,
            "y": $($y+5),
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
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk IOPS Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk IOPS Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg OS Disk IOPS Consumed Percentage for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk IOPS Consumed Percentage",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk IOPS Consumed Percentage"
                        }
                        }
                    ],
                    "title": "Avg OS Disk IOPS Consumed Percentage for $ResourceName",
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
"@ | convertfrom-json
        $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+7) -Value $value.$($id+7)
        
    $value=@"
    {
        "$($id+8)": {
            "position": {
            "x": 15,
            "y": $($y+5),
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
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk Latency",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk Latency (Preview)"
                        }
                        }
                    ],
                    "title": "Avg OS Disk Latency (Preview) for $ResourceName",
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
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {
                "content": {
                "options": {
                    "chart": {
                    "metrics": [
                        {
                        "resourceMetadata": {
                            "id": "$ResourceID"
                        },
                        "name": "OS Disk Latency",
                        "aggregationType": 4,
                        "namespace": "microsoft.compute/virtualmachines",
                        "metricVisualization": {
                            "displayName": "OS Disk Latency (Preview)"
                        }
                        }
                    ],
                    "title": "Avg OS Disk Latency (Preview) for $ResourceName",
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
"@ | convertfrom-json
    $starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+8) -Value $value.$($id+8)


$value = @"
{
"$($id+9)": {
    "position": {
      "x": 0,
      "y": $($y+9),
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
                    "id": "$ResourceID"
                  },
                  "name": "Data Disk Read Operations/Sec",
                  "aggregationType": 4,
                  "namespace": "microsoft.compute/virtualmachines",
                  "metricVisualization": {
                    "displayName": "Data Disk Read Operations/Sec",
                    "resourceDisplayName": "$ResourceName"
                  }
                }
              ],
              "title": "Avg Data Disk Read Operations/Sec for $ResourceName by LUN",
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
                "top": 10
              }
            }
          }
        }
      }
    }
  }
}
"@ | convertfrom-json
$starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+9) -Value $value.$($id+9)

$value=@"
{
"$($id+10)": {
    "position": {
      "x": 5,
      "y": $($y+9),
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
                    "id": "$ResourceID"
                  },
                  "name": "Data Disk Write Operations/Sec",
                  "aggregationType": 4,
                  "namespace": "microsoft.compute/virtualmachines",
                  "metricVisualization": {
                    "displayName": "Data Disk Write Operations/Sec",
                    "resourceDisplayName": "$ResourceName"
                  }
                }
              ],
              "title": "Avg Data Disk Write Operations/Sec for $ResourceName by LUN",
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
                "top": 10
              }
            }
          }
        }
      }
    }
  }
}
"@ | convertfrom-json
$starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+10) -Value $value.$($id+10)

$value=@"
{
  "$($id+11)": {
    "position": {
      "x": 10,
      "y": $($y+9),
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
                    "id": "$ResourceID"
                  },
                  "name": "Network In Total",
                  "aggregationType": 1,
                  "namespace": "microsoft.compute/virtualmachines",
                  "metricVisualization": {
                    "displayName": "Network In Total",
                    "resourceDisplayName": "$ResourceName"
                  }
                }
              ],
              "title": "Sum Network In Total for $ResourceName",
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
"@ | convertfrom-json
$starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+11) -Value $value.$($id+11)

$value=@"
{
  "$($id+12)": {
    "position": {
      "x": 15,
      "y": $($id+9),
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
                    "id": "$ResourceID"
                  },
                  "name": "Network Out Total",
                  "aggregationType": 1,
                  "namespace": "microsoft.compute/virtualmachines",
                  "metricVisualization": {
                    "displayName": "Network Out Total",
                    "resourceDisplayName": "$ResourceName"
                  }
                }
              ],
              "title": "Sum Network Out Total for $ResourceName",
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
"@ | convertfrom-json
$starter.properties.lenses."0".parts | add-Member -MemberType NoteProperty -Name $($id+12) -Value $value.$($id+12)

if ($counter -gt 10) 
{
  $filenameCount += 1
  $starter.name = "$DashboardName-$filenameCount"
  $starter.tags.'hidden-title' = "$DashboardName-$filenameCount"
  Write-host -ForegroundColor yellow "Outputing to $DashboardName-$filenameCount"
  $outFilePath = "$outputFolder\$DashboardName-$filenameCount.json"
  $starter | ConvertTo-Json -depth 100 | Out-File $outFilePath
  $counter = 1
}

    $y += 13
    $id += 13
    $counter += 1
}

$filenameCount
if ($filenameCount -eq 0)
{
  Write-host -ForegroundColor yellow "Outputing to $DashboardName"
  $outFilePath = "$outputFolder\$DashboardName.json"
} else {
  $starter.name = "$DashboardName-$filenameCount"
  $starter.tags.'hidden-title' = "$DashboardName-$filenameCount"
  Write-host -ForegroundColor yellow "Outputing to --->$DashboardName"
  $outFilePath = "$outputFolder\$DashboardName-$filenameCount.json"
}
$outFilePath
$starter | ConvertTo-Json -depth 100 | Out-File $outFilePath