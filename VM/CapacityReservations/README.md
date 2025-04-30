# List status of Capacity Reservation by SKU
This [script](https://github.com/JayWitt/AzureOperationGuide/blob/master/VM/CapacityReservations/GetCapacityReservations.ps1) can be run to generate a CRvms.csv file that will list the SKUs and if they support Capacity Reservations or not. 

The $output variable can be used as needed but the script will output it as a CSV file to ease the process of determining the disposition of a specific SKU.

Also note that this command is hard coded to go to the eastus region but can be switched to another region that may have additional SKUs.