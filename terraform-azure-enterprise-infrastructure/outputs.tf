output "resource_groups" {
  value       = module.resource_groups.resource_groups
  description = "Summary map of all deployed resource groups"
}

output "vnets" {
  value       = module.networking.vnets
  description = "Summary map of all deployed Virtual Networks"
}

output "subnets" {
  value       = module.networking.subnets
  description = "Summary map of all deployed Subnets"
}

output "storage_accounts" {
  value       = module.storage.storage_accounts
  description = "Map of all provisioned Storage Accounts and primary blob endpoints"
}

output "key_vault_uris" {
  value = {
    for k, v in module.security.key_vaults : k => v.vault_uri
  }
  description = "Map of Key Vault endpoints for application secret consumption"
}
