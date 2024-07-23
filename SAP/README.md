# Mass SAP Quality Check Script Report Gatherer

With multiple servers making up an SAP landscape, you will sometimes need to run the [SAP Quality Check script](https://github.com/Azure/SAP-on-Azure-Scripts-and-Utilities/blob/main/QualityCheck/Readme.md) against a large number of VMs. The output is stored in an HTML file. 

You can point this Mass SAP Qualtiy Check Script Report Gatherer script to the folder where all of the HTML files are saved and it will parse them and pull out the non "OK" findings and export them into an excel file for easier review.

## How to use it
1. Put all of the Quality Check script output into a folder.
1. Download the [script](SAP/MassQC-Check.ps1).
1. Update the $folderpath variable with the path to where the HTML output reports are stored.
1. Run the Powershell command.
1. The script will output the consolidated report into a file named QCOutput.xlsx in the same folder path set in the variable.

