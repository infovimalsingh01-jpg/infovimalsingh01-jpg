output "vnets" {
  value = {
    for k, v in azurerm_virtual_network.vnet : k => {
      id                  = v.id
      name                = v.name
      resource_group_name = v.resource_group_name
      address_space       = v.address_space
    }
  }
  description = "Map of all provisioned Virtual Networks"
}

output "subnets" {
  value = {
    for k, v in azurerm_subnet.subnet : k => {
      id                   = v.id
      name                 = v.name
      address_prefixes     = v.address_prefixes
      virtual_network_name = v.virtual_network_name
    }
  }
  description = "Map of all provisioned Subnets keyed by vnet_key.subnet_key"
}

output "subnet_ids" {
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
  description = "Key-value map of subnet names to IDs"
}

output "nsgs" {
  value = {
    for k, v in azurerm_network_security_group.nsg : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Map of all Network Security Groups"
}
