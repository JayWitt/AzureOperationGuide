# Lookup VM SKU Detail Script
This [script](https://github.com/JayWitt/AzureOperationGuide/blob/master/VM/LookupSKU.ps1) takes two parameters and is used to quickly lookup characteristics of Azure VMs for a given region.

In order to make the script fast, when the script is first run, it runs for a longer period of time because it goes out and collects the list of VM SKUs that are available within a region and then uses the public billing API to go and collect the retail pricing for those VMs. It stores all of this data into a CSV file that is then used by subsequent runs of the script to make it much faster. The CSV file that is created will only contain the information for a single region, so every time that you would change the region, a new file would be created.

```Powershell
LookupSKU.ps1 <region> <SKU>
```

* **Region** - This should be the short name version of the region (i.e. eastus or centralus)
* **SKU** - This could be represented by the full name with underscores (i.e. Standard_M128ms_v2) or just the part that represents the name (i.e. m128ms_v2)


![LookupSKUExample](https://github.com/JayWitt/AzureOperationGuide/raw/master/VM/LookupSKU/LookupSKUExample.png)

**NOTE** - The results of this command mostly comes from the [Get-AzComputeResourceSku](https://learn.microsoft.com/en-us/powershell/module/az.compute/get-azcomputeresourcesku?view=azps-10.1.0) Powershell command. The results between VM SKUs may vary because not all output is consistent between SKUs.

There are some data that is highlighted in yellow to help make it easier to readable.

**PRO-TIP** - I have created a Windows Command file that I keep stored in a folder that resides in my %PATH% that then also takes two inputs and passes them to this powershell script. This helps to make this data at your fingertips. Just open a command prompt and type in ```lookupsku eastus M128ms_v2``` to generate the results shown in the above screen shot.

```Command
@echo off
powershell %onedriveconsumer%\scripts\lookupsku.ps1 %1 %2
```
