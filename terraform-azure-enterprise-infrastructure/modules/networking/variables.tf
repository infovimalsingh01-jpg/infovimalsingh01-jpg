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
  description = "Nested map of VNets and Subnets to deploy via for_each"
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
  description = "Map of Network Security Groups with nested security rule definitions"
}

variable "default_tags" {
  type        = map(string)
  default     = {}
  description = "Default tags applied to networking resources"
}
