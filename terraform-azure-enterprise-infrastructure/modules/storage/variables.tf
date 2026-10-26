variable "storage_accounts" {
  type = map(object({
    name                     = string
    location                 = string
    resource_group_name      = string
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    account_kind             = optional(string, "StorageV2")
    versioning_enabled       = optional(bool, true)
    retention_days           = optional(number, 14)
    tags                     = optional(map(string), {})
    containers = optional(map(object({
      name                  = string
      container_access_type = optional(string, "private")
    })), {})
  }))
  description = "Map of Storage Accounts and nested Blob Containers to provision using for_each"
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Baseline enterprise tags"
}
