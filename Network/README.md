# Networking

[Links to Azure IP Addresses](https://github.com/JayWitt/AzureOperationGuide/blob/master/Network/IPAddressReference.md)

[Useful Log Analytics Queries](https://github.com/JayWitt/AzureOperationGuide/blob/master/Network/LogAnalyticsQueries.md)

The following [link](https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security#grant-access-from-an-internet-ip-range) talks about why some PaaS services can't have firewalls for services that are in the same region.

## Tools/Scripts

**IPWhois** - [ipwhois.ps1](https://github.com/JayWitt/AzureOperationGuide/blob/master/Network/ipwhois.ps1)

This script accepts a single parameter and it could be a FQDN name or an IP address and is used to quickly search the ARIN database to see who owns the IP address or the IP address behind the FQDN name

```
.\ipwhois.ps1 bing.com
```

**WhatIsMyIp** - [whatismyip.ps1](https://github.com/JayWitt/AzureOperationGuide/blob/master/Network/whatismyip.ps1)

This script can just be run and it will return the internet IP address of your connection.

```
.\whatismyip.ps1
```

**IPSearch** - [ipsearch.ps1](https://github.com/JayWitt/AzureOperationGuide/blob/master/Network/ipsearch.ps1)

This script accepts a single parameter which could be a FQDN name or IP address. It then attempts to find if it is in Azure and if it is found there, it will try to return which Service Tag it belongs to and which Azure region from which it is served. If it is not in Azure, it will attempt to use the free IP Geolocation service (https://ipgeolocation.io) to lookup where the IP address is physically located. **NOTE** This script needs to have the $apikey value updated with a free API key that you can get by registering at https://ipgeolocation.io.

```
.\ipsearch.ps1 52.168.112.64
```

