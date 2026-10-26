# =====================================================================================================================
# ENTERPRISE AZURE INFRASTRUCTURE MODULE ORCHESTRATION
# Architecture: Clean, modular orchestration utilizing Terraform `for_each` across all cloud resources
# Author: Vimal Pratap Singh (Senior DevOps & Cloud Platform Architect)
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# 1. RESOURCE GROUPS MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "resource_groups" {
  source = "./modules/resource_group"

  resource_groups = var.resource_groups
  default_tags    = var.default_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. NETWORKING MODULE (VNETS, FLATTENED SUBNETS, NSGS & ASSOCIATIONS VIA FOR_EACH)
# ---------------------------------------------------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  vnets                   = var.vnets
  network_security_groups = var.network_security_groups
  default_tags            = var.default_tags

  depends_on = [module.resource_groups]
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. STORAGE ACCOUNTS & BLOB CONTAINERS (STATE LOCKING & LOGGING VIA FOR_EACH)
# ---------------------------------------------------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  storage_accounts = var.storage_accounts
  default_tags     = var.default_tags

  depends_on = [module.resource_groups]
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. SECURITY & AZURE KEY VAULT MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  key_vaults   = var.key_vaults
  tenant_id    = var.tenant_id
  default_tags = var.default_tags

  depends_on = [module.resource_groups]
}
