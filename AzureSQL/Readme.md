 # Azure SQL Notes

This page is devoted to storing general notes about Azure SQL.


## Quick Add SQL Firewall Script
You can use this script to quickly add a set of IP addresses to a SQL.

[SetSQLFirewallRule.ps1](https://github.com/JayWitt/AzureOperationGuide/raw/main/SetSQLFirewallrule.ps1)

### How to use:
1. Download the script
1. Login to your Azure subscription that has the SQL server.
1. Run the script. You will be prompted for the following values.
   1. **What should be used as the prefix to the Firewall rules?** This is the text string that will be the first part of the firewall rules. This name will have a numeric value appended to it.
   1. **What is the Resource Group Name that holds the SQL server?** This is the Resource Group Name
   1. **What is the name of the SQL server** This is the name of the SQL server. This is just the name and not the fully qualified domain name version of the SQL server.
   1. **What are the IP ranges** This is where you can just copy the string of IP addresses posted on many of the web sites (Referenced below).
1. After you run the script, it will create firewall rules on your SQL server based upon the given IP addresses.

![IP Address Example](https://github.com/JayWitt/AzureOperationGuide/raw/main/AzureSQL/ipaddrs.png)

![Script Output](https://github.com/JayWitt/AzureOperationGuide/raw/main/AzureSQL/SQLFirewallIPs.png)

[Link to Azure IP Addresses](https://github.com/JayWitt/AzureOperationGuide/blob/main/Network/IPAddressReference.md)