# Application Gateways

* [Application Gateway Troubleshooting Guide](https://github.com/JayWitt/AzureOperationGuide/blob/main/AppGateway/Troubleshooting.md)
* [Useful Curl Commands](https://github.com/JayWitt/AzureOperationGuide/blob/main/AppGateway/UsefulCurl.md)
* [Application Gateway Governance](https://github.com/JayWitt/AzureOperationGuide/blob/main/AppGateway/Governance.md)

## Application Gateway Performance

In general the performance of the App Gateways can be referenced in the following table:

|App Gateway SKU| Throughput information|
|:-----:|----|
| v1 | This depends on the average back-end page response sizes. The table can be found [here](https://docs.microsoft.com/en-us/azure/application-gateway/features#sizing) but in general depending on the size of the instance, it could range from 7.5 Mbps to 200 Mbps.|
| v2 | [Each capacity unit is composed of at most: 1 compute unit, 2500 persistent connections, and 2.22-Mbps throughput.](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-autoscaling-zone-redundant#pricing)