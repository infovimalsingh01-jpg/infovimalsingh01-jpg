# ---------------------------------------------------------------------------------------------------------------------
# 1. VIRTUAL NETWORKS DEPLOYED USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnets

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = merge(var.default_tags, lookup(each.value, "tags", {}))
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. FLATTENED SUBNETS DEPLOYED USING FOR_EACH
# Demonstrates advanced HCL2 nested collection flattening to avoid index-shift and count issues
# ---------------------------------------------------------------------------------------------------------------------
locals {
  subnets_flat = merge([
    for vnet_key, vnet in var.vnets : {
      for subnet_key, subnet in vnet.subnets : "${vnet_key}.${subnet_key}" => {
        name              = subnet.name
        vnet_key          = vnet_key
        vnet_name         = azurerm_virtual_network.vnet[vnet_key].name
        rg_name           = azurerm_virtual_network.vnet[vnet_key].resource_group_name
        address_prefixes  = subnet.address_prefixes
        service_endpoints = subnet.service_endpoints
        nsg_key           = subnet.nsg_key
      }
    }
  ]...)
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets_flat

  name                 = each.value.name
  resource_group_name  = each.value.rg_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. NETWORK SECURITY GROUPS & DYNAMIC SECURITY RULES USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each = var.network_security_groups

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = merge(var.default_tags, lookup(each.value, "tags", {}))

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. SUBNET TO NSG ASSOCIATIONS USING FOR_EACH
# ---------------------------------------------------------------------------------------------------------------------
locals {
  subnet_nsg_associations = {
    for k, v in local.subnets_flat : k => v
    if v.nsg_key != null && contains(keys(azurerm_network_security_group.nsg), v.nsg_key)
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = local.subnet_nsg_associations

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}
