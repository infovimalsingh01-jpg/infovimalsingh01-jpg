output "key_vaults" {
  value = {
    for k, v in azurerm_key_vault.kv : k => {
      id        = v.id
      name      = v.name
      vault_uri = v.vault_uri
    }
  }
  description = "Map of all provisioned Key Vaults"
}

output "key_vault_ids" {
  value       = { for k, v in azurerm_key_vault.kv : k => v.id }
  description = "Map of Key Vault resource IDs"
}

output "secrets" {
  value = {
    for k, v in azurerm_key_vault_secret.secret : k => {
      id           = v.id
      name         = v.name
      key_vault_id = v.key_vault_id
    }
  }
  sensitive   = true
  description = "Map of created secret IDs"
}
