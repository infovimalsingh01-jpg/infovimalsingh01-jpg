# 🚀 Azure Enterprise Infrastructure with Terraform (`for_each` Architecture)

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-844fba?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure Provider](https://img.shields.io/badge/azurerm-~%3E3.80-0078d4?style=flat-square&logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![Security Scan](https://img.shields.io/badge/tfsec%20%7C%20checkov-Passing-10b981?style=flat-square&logo=security&logoColor=white)](https://github.com/aquasecurity/tfsec)
[![FinOps](https://img.shields.io/badge/Infracost-Enabled-00d2ff?style=flat-square&logo=infracost&logoColor=black)](https://www.infracost.io/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

> **Architected by:** [Vimal Pratap Singh](https://github.com/infovimalsingh01-jpg) (Senior DevOps & Cloud Platform Architect)  
> **Repository Purpose:** Production-grade, modular, declarative Infrastructure-as-Code (IaC) provisioning multi-region Azure cloud foundations using **`for_each`** across all frequently used cloud resources.

---

## 🏛️ Architecture & End-to-End DevSecOps Pipeline

This repository implements the standardized 7-stage enterprise delivery framework:

```
[ Terraform Git Repo ] 
         |
         v
[ Linting (tflint) & Format (terraform fmt) ]
         |
         v
[ Security Scanning (tfsec / Checkov / Trivy) ]
         |
         v
[ Cost Estimation (Infracost) ]
         |
         v
[ Terraform Plan & Drift Detection Pipeline ]
         |
         v
[ Manual Peer Approval (Production Gate) ]
         |
         v
[ Terraform Apply (Remote State locked via Azure Blob Storage) ]
```

---

## 💡 Why `for_each` over `count` in Production?

| Criterion | Using `count` (Anti-pattern for resources) | Using `for_each` (Enterprise Best Practice) |
| :--- | :--- | :--- |
| **State Tracking** | Keyed by numeric array index (`[0]`, `[1]`, `[2]`). | Keyed by deterministic string keys (`["hub_vnet"]`, `["aks_nodes"]`). |
| **Resource Removal** | Removing index `[0]` forces Terraform to destroy and recreate all subsequent resources (`[1]` becomes `[0]`). | Removing an item only destroys that specific resource. Zero impact on peers. |
| **Readability** | Obscure indexing in plan outputs. | Intuitive, clear diffs displaying exact resource keys being modified. |
| **Granularity** | Difficult to customize individual properties per item. | Each item in the map can specify unique tags, CIDRs, locations, and rules. |

---

## 📦 Frequently Used Azure Resources Implemented

### 1. Resource Groups (`modules/resource_group`)
* Provisions multiple resource groups across tiers (Hub, Spoke, Security, State) using `for_each`.
* Merges base enterprise tags (`ManagedBy`, `CostCenter`, `Environment`) with custom resource tags.

### 2. Networking Tier (`modules/networking`)
* **Virtual Networks (`azurerm_virtual_network`)**: Provisions multiple VNets simultaneously using `for_each`.
* **Flattened Subnets (`azurerm_subnet`)**: Uses advanced HCL `merge()` and `flatten()` locals to extract subnets from nested VNet maps into a single flat map keyed by `vnet_key.subnet_key`.
* **Network Security Groups (`azurerm_network_security_group`)**: Dynamic security rules created using `dynamic "security_rule"` blocks iterated over input rules arrays.
* **Subnet-to-NSG Associations**: Deterministically binds subnets to security groups via `for_each`.

### 3. Secure Storage Accounts & Containers (`modules/storage`)
* Enforces **TLS 1.2 minimum**, **HTTPS only**, and disables public blob access.
* Configures **Blob Versioning** and soft-delete retention policies.
* Provisions Blob Containers across storage accounts using flattened `for_each`.

### 4. Azure Key Vault & Secrets (`modules/security`)
* Provisions Key Vault instances with purge protection and soft-delete enabled.
* Manages encrypted application secrets using `azurerm_key_vault_secret` iterated via `for_each`.

---

## 📁 Repository Directory Structure

```text
terraform-azure-enterprise-infrastructure/
├── .github/
│   └── workflows/
│       └── terraform-ci-cd.yml      # Complete 7-stage CI/CD GitHub Actions workflow
├── .tflint.hcl                      # TFLint rules configuration for Azure provider
├── .gitignore                       # Production Terraform gitignore
├── README.md                        # Architectural and operational documentation
├── versions.tf                      # Terraform & AzureRM provider version constraints
├── providers.tf                     # AzureRM features and remote state backend template
├── variables.tf                     # Root variables with type-safe schema validation
├── terraform.tfvars                 # Real-world enterprise configuration sample
├── outputs.tf                       # Formatted outputs with resource IDs and endpoints
├── main.tf                          # Root module orchestrator calling child modules
└── modules/
    ├── resource_group/              # Multi-tier Resource Group module with for_each
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── networking/                  # Hub & Spoke VNets, Subnets, and NSGs with for_each
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── storage/                     # Storage Accounts & Blob Containers with for_each
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── security/                    # Key Vault & Secrets with for_each
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⚡ Quickstart & Local Execution

### 1. Prerequisites
* **Terraform CLI** `>= 1.5.0`
* **Azure CLI** (`az login`)
* **TFLint** & **tfsec** (optional for local pre-commit checks)

### 2. Initialize Backend & Download Providers
```bash
# Initialize Terraform modules and Azure provider plugins
terraform init
```

### 3. Validate Code Quality & Canonical Format
```bash
# Check formatting
terraform fmt -check -recursive

# Validate HCL syntax and internal references
terraform validate
```

### 4. Speculative Execution Plan
```bash
# Generate speculative plan using variables defined in terraform.tfvars
terraform plan -out=tfplan
```

### 5. Review & Apply to Target Environment
```bash
# Apply the exact verified plan artifact to Azure
terraform apply tfplan
```

---

## 🛡️ DevSecOps & Shift-Left Security Checks

Run the automated static security scans locally prior to pushing:

```bash
# Run tfsec for Azure security misconfigurations
tfsec .

# Run Checkov for compliance & CIS benchmark policies
checkov -d . --framework terraform

# Run Infracost for pre-merge cost diff analysis
infracost breakdown --path .
```

---

## 📄 License
This project is licensed under the MIT License - feel free to use and adapt it for your cloud engineering workflows!
