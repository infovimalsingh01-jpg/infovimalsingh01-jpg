# ---------------------------------------------------------------------------------------------------------------------
# 1. STORAGE ACCOUNTS DEPLOYED USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts

  name                            = lower(replace(each.value.name, "/[^a-z0-9]/", ""))
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = each.value.account_tier
  account_replication_type        = each.value.account_replication_type
  account_kind                    = each.value.account_kind
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = each.value.versioning_enabled
    delete_retention_policy {
      days = each.value.retention_days
    }
  }

  tags = merge(var.default_tags, lookup(each.value, "tags", {}))
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. BLOB CONTAINERS DEPLOYED USING FOR_EACH ACROSS ALL STORAGE ACCOUNTS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  containers_flat = merge([
    for sa_key, sa in var.storage_accounts : {
      for container_key, container in lookup(sa, "containers", {}) : "${sa_key}.${container_key}" => {
        name                  = container.name
        storage_account_name  = azurerm_storage_account.sa[sa_key].name
        container_access_type = container.container_access_type
      }
    }
  ]...)
}

resource "azurerm_storage_container" "sc" {
  for_each = local.containers_flat

  name                  = each.value.name
  storage_account_name  = each.value.storage_account_name
  container_access_type = each.value.container_access_type
}
