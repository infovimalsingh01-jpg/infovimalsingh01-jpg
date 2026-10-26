output "resource_groups" {
  value = {
    for k, v in azurerm_resource_group.rg : k => {
      id       = v.id
      name     = v.name
      location = v.location
      tags     = v.tags
    }
  }
  description = "Map of all created resource groups keyed by their input map key"
}

output "resource_group_names" {
  value       = { for k, v in azurerm_resource_group.rg : k => v.name }
  description = "Map of resource group names by input key for referencing in downstream modules"
}

output "resource_group_ids" {
  value       = { for k, v in azurerm_resource_group.rg : k => v.id }
  description = "Map of resource group resource IDs by input key"
}
