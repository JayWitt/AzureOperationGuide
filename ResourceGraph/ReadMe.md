# Useful Resource Graph Queries

The following table contains useful Resource Graph Queries:

|Description|Query|
|-----------|-----|
|Show all virtual machines ordered by name in descending order|```kusto 
project name, location, type | where type =~ 'Microsoft.Compute/virtualMachines' | order by name  desc 
```|
|Count virtual machines by OS Type (Windows or Linux)|```kusto where type =~ 'Microsoft.Compute/virtualMachines' | summarize count() by tostring(properties.storageProfile.osDisk.osType) ```|
|List virtual machines that match something in their name (Example is for SQL)|```kusto where type =~ 'microsoft.compute/virtualmachines' and name contains "sql" | project name | order by name asc```|
|List virtual machines that used a 2012 version of the marketplace image (By SKU)|```kusto where type =~ 'microsoft.compute/virtualmachines' and tostring(properties.storageProfile.imageReference.sku)contains "2012" | project name, tostring(properties.storageProfile.imageReference.sku) | order by name asc ```|
|List virtual machines that used a SQL based marketplace image (By Offer)|```kusto where type =~ 'microsoft.compute/virtualmachines' and tostring(properties.storageProfile.imageReference.offer) contains "sql" | project name, tostring(properties.storageProfile.imageReference.offer) | order by name asc ```|


