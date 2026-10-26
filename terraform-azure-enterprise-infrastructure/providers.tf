provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# REMOTE STATE BACKEND CONFIGURATION (AZURE BLOB STORAGE WITH LEASE LOCKING)
# Uncomment and configure with your Azure Storage backend details for production state management
# ---------------------------------------------------------------------------------------------------------------------
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state-prod"
#     storage_account_name = "sttfstateprodvimal01"
#     container_name       = "tfstate"
#     key                  = "infrastructure/prod.terraform.tfstate"
#     use_azuread_auth     = true
#   }
# }
