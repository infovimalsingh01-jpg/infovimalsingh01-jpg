variable "environment" {
  type        = string
  default     = "prod"
  description = "Target deployment environment (e.g., dev, qa, staging, prod)"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Primary Azure region for infrastructure provisioning"
}

variable "tenant_id" {
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
  description = "Azure Active Directory Tenant ID for Key Vault and RBAC"
}

variable "default_tags" {
  type = map(string)
  default = {
    ManagedBy  = "Terraform"
    Architect  = "Vimal Pratap Singh"
    Project    = "Cloud Enterprise Foundation"
    CostCenter = "DevOps-Platform-99"
  }
  description = "Global enterprise governance tags"
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Resource groups to provision via for_each"
}

variable "vnets" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    address_space       = list(string)
    dns_servers         = optional(list(string), null)
    tags                = optional(map(string), {})
    subnets = map(object({
      name              = string
      address_prefixes  = list(string)
      service_endpoints = optional(list(string), [])
      nsg_key           = optional(string, null)
    }))
  }))
  description = "Virtual Networks and Subnets deployed with nested for_each"
}

variable "network_security_groups" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
      description                = optional(string, null)
    }))
  }))
  default     = {}
  description = "Network Security Groups with rules managed via for_each"
}

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
  description = "Storage Accounts and Blob Containers provisioned using for_each"
}

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
  default     = {}
  description = "Key Vaults and secrets managed with for_each"
}
