output "storage_accounts" {
  value = {
    for k, v in azurerm_storage_account.sa : k => {
      id                    = v.id
      name                  = v.name
      primary_blob_endpoint = v.primary_blob_endpoint
    }
  }
  description = "Map of all provisioned Storage Accounts"
}

output "storage_account_names" {
  value       = { for k, v in azurerm_storage_account.sa : k => v.name }
  description = "Map of storage account names by input key"
}

output "containers" {
  value = {
    for k, v in azurerm_storage_container.sc : k => {
      id                   = v.id
      name                 = v.name
      storage_account_name = v.storage_account_name
    }
  }
  description = "Map of all provisioned Storage Containers"
}
