# Azure Acitve Directory


## Important Commands


### Return Azure Active Directory Object ID based on users e-mail address (or UPN)
```AzureCli
az ad user show --id <e-mailAddress> --query objectId
```


### Return Service Principal name based upon objectID
```AzureCli
az ad sp show --id <objectID> --query displayName
```