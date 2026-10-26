variable "key_vaults" {
  type = map(object({
    name                       = string
    location                   = string
    resource_group_name        = string
    sku_name                   = optional(string, "standard")
    soft_delete_retention_days = optional(number, 90)
    purge_protection_enabled   = optional(bool, false)
    tags                       = optional(map(string), {})
    secrets = optional(map(object({
      name         = string
      value        = string
      content_type = optional(string, "text/plain")
    })), {})
  }))
  description = "Map of Key Vaults and secrets to provision using for_each"
}

variable "tenant_id" {
  type        = string
  description = "Azure Active Directory Tenant ID"
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Baseline enterprise governance tags"
}
