data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# 1. AZURE KEY VAULTS DEPLOYED USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault" "kv" {
  for_each = var.key_vaults

  name                       = lower(replace(each.value.name, "/[^a-zA-Z0-9-]/", ""))
  location                   = each.value.location
  resource_group_name        = each.value.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = each.value.sku_name
  soft_delete_retention_days = each.value.soft_delete_retention_days
  purge_protection_enabled   = each.value.purge_protection_enabled
  enable_rbac_authorization  = true

  tags = merge(var.default_tags, lookup(each.value, "tags", {}))
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. KEY VAULT SECRETS DEPLOYED USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
locals {
  secrets_flat = merge([
    for kv_key, kv in var.key_vaults : {
      for secret_key, secret in lookup(kv, "secrets", {}) : "${kv_key}.${secret_key}" => {
        name         = secret.name
        value        = secret.value
        content_type = secret.content_type
        key_vault_id = azurerm_key_vault.kv[kv_key].id
      }
    }
  ]...)
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = local.secrets_flat

  name         = each.value.name
  value        = each.value.value
  key_vault_id = each.value.key_vault_id
  content_type = each.value.content_type
}
