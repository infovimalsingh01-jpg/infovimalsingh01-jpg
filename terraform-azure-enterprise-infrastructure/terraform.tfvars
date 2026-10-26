environment = "prod"
location    = "eastus"
tenant_id   = "72f988bf-86f1-41af-91ab-2d7cd011db47"

default_tags = {
  ManagedBy   = "Terraform"
  Architect   = "Vimal Pratap Singh"
  Project     = "Azure Enterprise Landing Zone"
  Environment = "Production"
  CostCenter  = "DevOps-Platform-99"
}

# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE GROUPS (PROVISIONED VIA FOR_EACH)
# ---------------------------------------------------------------------------------------------------------------------
resource_groups = {
  hub_network = {
    name     = "rg-hub-network-prod"
    location = "eastus"
    tags     = { Tier = "Hub", Network = "Core" }
  }
  spoke_workloads = {
    name     = "rg-spoke-workloads-prod"
    location = "eastus"
    tags     = { Tier = "Spoke", Workload = "AKS-Microservices" }
  }
  security_core = {
    name     = "rg-security-core-prod"
    location = "eastus"
    tags     = { Tier = "Security", Compliance = "CIS-Benchmark" }
  }
  storage_state = {
    name     = "rg-terraform-state-prod"
    location = "eastus"
    tags     = { Tier = "StateBackend", Purpose = "LeaseLock" }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# NETWORK SECURITY GROUPS & RULES (PROVISIONED VIA FOR_EACH & DYNAMIC BLOCKS)
# ---------------------------------------------------------------------------------------------------------------------
network_security_groups = {
  nsg_app = {
    name                = "nsg-app-prod"
    location            = "eastus"
    resource_group_name = "rg-spoke-workloads-prod"
    security_rules = [
      {
        name                       = "Allow-HTTPS-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow public HTTPS traffic to Ingress"
      },
      {
        name                       = "Allow-VNet-Internal"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
        description                = "Allow intra-VNet communication"
      }
    ]
  }
  nsg_db = {
    name                = "nsg-database-prod"
    location            = "eastus"
    resource_group_name = "rg-spoke-workloads-prod"
    security_rules = [
      {
        name                       = "Allow-Postgres-From-App"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "10.10.2.0/24"
        description                = "Allow PostgreSQL access strictly from App Subnet"
      },
      {
        name                       = "Deny-Internet-Inbound"
        priority                   = 900
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Explicit block of public Internet to Database Tier"
      }
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# VIRTUAL NETWORKS & NESTED SUBNETS (DEPLOYED VIA FOR_EACH & ADVANCED LOCAL FLATTENING)
# ---------------------------------------------------------------------------------------------------------------------
vnets = {
  hub_vnet = {
    name                = "vnet-hub-prod-eastus"
    location            = "eastus"
    resource_group_name = "rg-hub-network-prod"
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["168.63.129.16"]
    subnets = {
      gateway = {
        name             = "GatewaySubnet"
        address_prefixes = ["10.0.0.0/24"]
      }
      firewall = {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.0.1.0/24"]
      }
      bastion = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.0.2.0/24"]
      }
    }
  }
  spoke_vnet = {
    name                = "vnet-spoke-workloads-prod-eastus"
    location            = "eastus"
    resource_group_name = "rg-spoke-workloads-prod"
    address_space       = ["10.10.0.0/16"]
    subnets = {
      aks_nodes = {
        name              = "snet-aks-nodes-prod"
        address_prefixes  = ["10.10.1.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        nsg_key           = "nsg_app"
      }
      db_private = {
        name              = "snet-db-private-prod"
        address_prefixes  = ["10.10.2.0/24"]
        service_endpoints = ["Microsoft.Storage"]
        nsg_key           = "nsg_db"
      }
      app_services = {
        name              = "snet-app-services-prod"
        address_prefixes  = ["10.10.3.0/24"]
        service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault"]
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# STORAGE ACCOUNTS & BLOB CONTAINERS (FOR_EACH WITH ENTERPRISE ENCRYPTION & VERSIONING)
# ---------------------------------------------------------------------------------------------------------------------
storage_accounts = {
  tfstate = {
    name                     = "sttfstateprodvimal01"
    location                 = "eastus"
    resource_group_name      = "rg-terraform-state-prod"
    account_tier             = "Standard"
    account_replication_type = "GRS"
    versioning_enabled       = true
    retention_days           = 30
    tags                     = { StateLock = "Active", Confidential = "High" }
    containers = {
      tfstate = {
        name                  = "tfstate"
        container_access_type = "private"
      }
      locks = {
        name                  = "locks"
        container_access_type = "private"
      }
    }
  }
  logs = {
    name                     = "stapplogsprodvimal01"
    location                 = "eastus"
    resource_group_name      = "rg-spoke-workloads-prod"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    retention_days           = 90
    containers = {
      audit_logs = {
        name                  = "audit-logs"
        container_access_type = "private"
      }
      app_metrics = {
        name                  = "app-metrics"
        container_access_type = "private"
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# KEY VAULTS & SECRETS (FOR_EACH WITH ZERO-TRUST ACCESS POLICIES)
# ---------------------------------------------------------------------------------------------------------------------
key_vaults = {
  app_vault = {
    name                       = "kv-prod-vimal-01"
    location                   = "eastus"
    resource_group_name        = "rg-security-core-prod"
    sku_name                   = "standard"
    soft_delete_retention_days = 90
    purge_protection_enabled   = true
    secrets = {
      db_connection = {
        name         = "DatabaseConnectionString"
        value        = "Server=tcp:db-cluster.internal;Database=production;Encrypt=true;"
        content_type = "connection-string"
      }
      api_key = {
        name         = "IntegrationApiKey"
        value        = "sec-key-vault-managed-token-99"
        content_type = "api-token"
      }
    }
  }
}
