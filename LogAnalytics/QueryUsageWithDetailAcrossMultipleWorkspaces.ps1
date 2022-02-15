Import-Module Az.ResourceGraph

$tenantID = "<insert Tenant ID here>"
$outputroot = "<path to where to store output>"

Connect-AzAccount -Tenant $tenantID

$LAWsSub = Search-AzGraph -first 1000 -query 'resources | where type == "microsoft.operationalinsights/workspaces" | distinct subscriptionId'

$lookup = @{
    "StorageFileLogs" = "AccountName";
    "AppDependencies" = "AppRoleName";
    "AppExceptions" = "AppRoleName";
    "AppMetrics" = "AppRoleName";
    "AppPerformanceCounters" = "AppRoleName";
    "AppRequests" = "AppRoleName";
    "AppTraces" = "AppRoleName";
    "InsightsMetrics" = "_ResourceId";
    "SqlAtpStatus" = "HostResourceId";
    "SqlVulnerabilityAssessmentScanStatus" = "Computer";
    "AppServiceConsoleLogs" = "_ResourceId";
    "AppServiceHTTPLogs" = "_ResourceId";
    "AppServicePlatformLogs" = "_ResourceId";
    "FunctionAppLogs" = "_ResourceId";
    "ADXCommand" = "_ResourceId";
    "MSSQL_AOOverview_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_AOWaiter_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_AOWaitstats_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_BatchRequests_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_BckBackups2_CL" = "DBName_s";
    "Event" = "_ResourceId";
    "ConfigurationData" = "_ResourceId";
    "ConfigurationChange" = "_ResourceId";
    "HealthStateChangeEvent" = "_ResourceId";
    "VMBoundPort" = "_ResourceId";
    "VMComputer" = "Computer";
    "VMConnection" = "Computer";
    "VMProcess" = "_ResourceId";
    "ContainerInventory" = "_ResourceId";
    "ContainerLog" = "_ResourceId";
    "ContainerNodeInventory" = "_ResourceId";
    "KubeEvents" = "_ResourceId";
    "KubeMonAgentEvents" = "_ResourceId";
    "KubeNodeInventory" = "_ResourceId";
    "KubePodInventory" = "ClusterId";
    "KubePVInventory" = "_ResourceId";
    "KubeServices" = "_ResourceId";
    "MSSQL_BlockingProcesses_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_CPUUsage_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_DBConnections_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_FileOverview_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_IOPerformance_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_MemoryOverview_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_PageLifeExpectancy2_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_SystemProps_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_TableSizes_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_Top10Statements_CL" = "PROVIDER_INSTANCE_s";
    "MSSQL_WaitPercs_CL" = "PROVIDER_INSTANCE_s";
    "Prometheus_HaClusterExporter_CL" = "metadata_hostname_s";
    "Prometheus_OSExporter_CL" = "instance_s";
    "SapHana_Alerts_CL" = "PROVIDER_INSTANCE_s";
    "SapHana_BackupCatalog_CL" = "SYSTEM_ID_s";
    "SapHana_DeltaMerge_Count_CL" = "PROVIDER_INSTANCE_s";
    "SapHana_Disks_CL" = "PROVIDER_INSTANCE_s";
    "SapHana_HostConfig_CL" = "HOST_s";
    "SapHana_HostInformation_CL" = "HOST_s";
    "SapHana_IO_Savepoint_CL" = "HOST_s";
    "SapHana_License_Status_CL" = "HOSTNAME_s";
    "SapHana_LoadHistory_CL" = "HOST_s";
    "SapHana_Mvcc_CL" = "HOST_s";
    "SapHana_size01_CL" = "SYSTEM_ID_s";
    "SapHana_SystemAvailability_CL" = "PROVIDER_INSTANCE_s";
    "SapHana_SystemOverview_CL" = "PROVIDER_INSTANCE_s";
    "SapHana_SystemReplication_CL" = "PROVIDER_INSTANCE_s";
    "NetworkMonitoring " = "CircuitName";
    "Operation" = "Computer";
    "ContainerProcess_CL" = "Computer";
    "Perf" = "_ResourceId";
    "Syslog" = "_ResourceId";
    "AzureNetworkAnalytics_CL" = "NSGList_s";
    "ContainerImageInventory" = "_ResourceId";
    "ContainerServiceLog" = "_ResourceId";
    "KubePodInventory_CL" = "_ResourceId";
    "ldap_request_errors_CL" = "_ResourceId";
    "LDAP_Request_Rrrors_TXT_CL" = "_ResourceId";
    "ldapstatuscheck_CL" = "_ResourceId";
    "SecurityDetection" = "_ResourceId";
    "SQLAssessmentRecommendation" = "Computer";
    "W3CIISLog" = "sSiteName";
    "SecurityEvent" = "Computer";
    "AzureDevOpsAuditing" = "ProjectId";
    "ACC_UAT_LOGINS_CL" = "_ResourceId";
    "ACC_UAT_WEB_CL" = "_ResourceId";
    "AegDeliveryFailureLogs" = "_ResourceId";
    "ApiManagementGatewayLogs" = "Url";
    "application_stats_apps_CL" = "_ResourceId";
    "AppServiceAntivirusScanAuditLogs" = "_ResourceId";
    "AppServiceAppLogs" = "_ResourceId";
    "AppServiceAuditLogs" = "_ResourceId";
    "AppServiceFileAuditLogs" = "_ResourceId";
    "CDBDataPlaneRequests" = "AccountName";
    "CDBPartitionKeyRUConsumption" = "AccountName";
    "CDBPartitionKeyStatistics" = "_ResourceId";
    "CDBQueryRuntimeStatistics" = "_ResourceId";
    "DatabricksAccounts" = "_ResourceId";
    "DatabricksClusters" = "_ResourceId";
    "DatabricksDBFS" = "_ResourceId";
    "DatabricksInstancePools" = "_ResourceId";
    "DatabricksJobs" = "_ResourceId";
    "DatabricksNotebook" = "_ResourceId";
    "DatabricksSecrets" = "_ResourceId";
    "DatabricksSQLPermissions" = "_ResourceId";
    "DatabricksSSH" = "_ResourceId";
    "DatabricksWorkspace" = "_ResourceId";
    "KubeEvents_CL" = "_ResourceId";
    "log_ambari_audit_CL" = "_ResourceId";
    "log_auth_CL" = "_ResourceId";
    "log_gateway_audit_CL" = "ClusterDnsName_s";
    "log_hivemetastore_CL" = "_ResourceId";
    "log_hiveserver2_CL" = "_ResourceId";
    "log_jupyter_CL"  = "_ResourceId";
    "log_mrjobsummary_CL" = "_ResourceId";
    "log_nodemanager_CL" = "_ResourceId";
    "log_oozie_CL" = "_ResourceId";
    "log_resourcemanager_CL" = "_ResourceId";
    "log_spark_CL" = "_ResourceId";
    "log_sparkapps_metrics_CL" = "_ResourceId";
    "log_sparkappsdrivers_CL" = "_ResourceId";
    "log_sparkappsexecutors_CL" = "_ResourceId";
    "log_timelineserver_CL" = "_ResourceId";
    "log_webhcat_CL" = "_ResourceId";
    "metrics_cluster_alerts_CL" = "ClusterName_s";
    "metrics_cpu_idle_CL" = "_ResourceId";
    "metrics_cpu_nice_CL" = "_ResourceId";
    "metrics_cpu_system_CL" = "_ResourceId";
    "metrics_cpu_user_CL" = "_ResourceId";
    "metrics_load_1min_CL" = "_ResourceId";
    "metrics_load_cpus_CL" = "_ResourceId";
    "metrics_load_nodes_CL" = "_ResourceId";
    "metrics_load_procs_CL" = "_ResourceId";
    "metrics_memory_buffer_CL" = "_ResourceId";
    "metrics_memory_cache_CL " = "_ResourceId";
    "metrics_memory_swap_CL" = "_ResourceId";
    "metrics_memory_total_CL" = "_ResourceId";
    "metrics_network_in_CL" = "_ResourceId";
    "metrics_network_out_CL" = "_ResourceId";
    "metrics_resourcemanager_clustermetrics_CL" = "_ResourceId";
    "metrics_resourcemanager_jvm_CL" = "ClusterName_s";
    "metrics_resourcemanager_queue_root_CL" = "ClusterName_s";
    "metrics_resourcemanager_queue_root_default_CL" = "ClusterName_s";
    "metrics_resourcemanager_queue_root_joblauncher_CL" = "_ResourceId";
    "metrics_resourcemanager_queue_root_thriftsvr_CL" = "_ResourceId";
    "metrics_sparkapps_CL" = "_ResourceId";
    "NWConnectionMonitorPathResult" = "ConnectionMonitorResourceId";
    "NWConnectionMonitorTestResult" = "ConnectionMonitorResourceId";
    "ranger_audit_logs_CL" = "_ResourceId";
    "SignalRServiceDiagnosticLogs" = "_ResourceId";
    "sparkapplication_stats_allexecutors_CL" = "_ResourceId";
    "sparkapplication_stats_apps_CL" = "_ResourceId";
    "sparkapplication_stats_executors_CL" = "_ResourceId";
    "sparkapplication_stats_jobs_CL" = "_ResourceId";
    "sparkapplication_stats_stages_CL" = "_ResourceId";
    "SparkListenerEvent_CL" = "_ResourceId";
    "SparkLoggingEvent_CL" = "_ResourceId";
    "SparkMetric_CL" = "_ResourceId";
    "StorageBlobLogs" = "_ResourceId";
    "SynapseGatewayApiRequests" = "_ResourceId";
    "SynapseRbacOperations" = "_ResourceId";
    "SynapseSqlPoolExecRequests" = "_ResourceId";
    "SynapseSqlPoolRequestSteps" = "_ResourceId";
    "SynapseSqlPoolSqlRequests" = "_ResourceId";
    "var_log_messages_CL" = "_ResourceId";
    "ABSBotRequests" = "_ResourceId";
    "ACC_LOGINS_CL" = "_ResourceId";
    "ACC_MTA_CL" = "_ResourceId";
    "ACC_RUNWF_CL" = "_ResourceId";
    "ACC_STAT_CL" = "_ResourceId";
    "ACC_WATCHDOG_CL" = "_ResourceId";
    "ACC_WEB_CL" = "_ResourceId";
    "ACC_WEBMDL_CL" = "_ResourceId";
    "ACC_WFSERVER_CL" = "_ResourceId";
    "AppBrowserTimings" = "_ResourceId";
    "AppEvents" = "_ResourceId";
    "NetworkMonitoring" = "CircuitName";
    "ContainerNodeInventory_CL" = "_ResourceId";
    "LDAP_Request_Errors_TXT_CL" = "_ResourceId";
    "ADAssessmentRecommendation" = "_ResourceId";
    "CDBControlPlaneRequests" = "_ResourceId";
    "ContainerRegistryLoginEvents" = "_ResourceId";
    "ContainerRegistryRepositoryEvents" = "_ResourceId";
    "LDAP_Status_CL" = "_ResourceId";
    "metrics_memory_cache_CL" = "_ResourceId";
    "AppPageViews" = "_ResourceId";
    "LAQueryLogs" = "AADEmail";
    "prod_usice_kafka_server_log_CL" = "_ResourceId";
    "SAP_Pacemaker_CL" = "_ResourceId";
    "SecureScoreControls" = "ControlName";
    "SecureScores" = "DisplayName";
    "SecurityNestedRecommendation" = "RecommendationName";
    "SecurityRecommendation" = "RecommendationName";
    "SecurityRegulatoryCompliance" = "ComplianceStandard";
    "WVDCheckpoints" = "_ResourceId";
    "WVDConnections" = "_ResourceId";
    "WVDErrors" = "_ResourceId";
    "Anomalies" = "RuleName";
    "AppServiceIPSecAuditLogs" = "_ResourceId";
    "AADNonInteractiveUserSignInLogs" = "OperationName";
    "AADServicePrincipalSignInLogs" = "OperationName";
    "PowerAutomate_CL" = "FlowDisplayName_s";
    "MicrosoftHealthcareApisAuditLogs" = "_ResourceId";
    "MSSQL_AOFailovers_CL" = "PROVIDER_INSTANCE_s";
}

foreach ($sub in $LAWsSub)
{
    $sub = $sub.subscriptionId

    Set-AzContext -Subscription $sub -Tenant $tenantID

    $LAWs = Search-AzGraph -first 1000 -Subscription $sub -query 'resources| where type == "microsoft.operationalinsights/workspaces"'

    foreach ($LAW in $LAWS)
    {
        $WorkspaceName = $LAW.name
        $ResourceGroupName = $LAW.resourceGroup

        write-output $WorkspaceName

        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName

        $query = 'Usage | where TimeGenerated > ago(32d) | where StartTime >= startofday(ago(31d)) and EndTime < startofday(now()) | where IsBillable == true | summarize BillableDataGB = sum(Quantity) / 1000. by bin(StartTime, 1d), DataType'

        $QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query $query

        $QueryResults.Results | Export-Csv -Path "$outputroot\data\$sub-$WorkspaceName.csv" -NoTypeInformation

        if ($($QueryResults.count) -gt 0)
        {
            $DataTypes = $queryResults.Results.DataType | Sort-Object | Get-Unique

            foreach ($DT in $DataTypes)
            {
                if ($lookup.ContainsKey($DT))
                {
                    $query = "$DT | summarize count() by $($lookup[$DT])"
                } else
                {
                    $query = "$DT | summarize count() by ResourceId"
                }

                $QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query $query

                $QueryResults.Results | Export-Csv -Path "$outputroot\detail\$sub-$WorkspaceName-$DT.csv" -NoTypeInformation
            }
        }

    }
}