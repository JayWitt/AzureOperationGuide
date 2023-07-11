# Lookup VM SKU Detail Script
This [script](https://github.com/JayWitt/AzureOperationGuide/blob/master/VM/LookupSKU.ps1) takes two parameters and is used to quickly lookup characteristics of Azure VMs for a given region.

In order to make the script fast, when the script is first run, it runs for a longer period of time because it goes out and collects the list of VM SKUs that are available within a region and then uses the public billing API to go and collect the retail pricing for those VMs. It stores all of this data into a CSV file that is then used by subsequent runs of the script to make it much faster. The CSV file that is created will only contain the information for a single region, so every time that you would change the region, a new file would be created.

```Powershell
LookupSKU.ps1 <region> <SKU>
```

* **Region** - This should be the short name version of the region (i.e. eastus or centralus)
* **SKU** - This could be represented by the full name with underscores (i.e. Standard_M128ms_v2) or just the part that represents the name (i.e. m128ms_v2)


![LookupSKUExample](https://github.com/JayWitt/AzureOperationGuide/raw/master/VM/LookupSKUExample.png)


