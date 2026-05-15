# Fixed Terraform with security best practices

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "terianaterraformstate"
    container_name       = "tfstate"
    key                  = "crop-predictor.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "predictor" {
  name     = "rg-crop-predictor-prod"
  location = "East US"

  tags = {
    environment = "production"
    service     = "crop-yield-predictor"
    managed_by  = "terraform"
  }
}

# Storage account with network restrictions
resource "azurerm_storage_account" "models" {
  name                     = "cropmodelstorage"
  resource_group_name      = azurerm_resource_group.predictor.name
  location                 = azurerm_resource_group.predictor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Network security
  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"
    ip_rules       = []
    virtual_network_subnet_ids = [
      azurerm_subnet.aks_subnet.id
    ]
    bypass = ["AzureServices"]
  }

  tags = {
    environment = "production"
    service     = "crop-yield-predictor"
  }
}

resource "azurerm_storage_container" "models" {
  name                  = "ml-models"
  storage_account_name  = azurerm_storage_account.models.name
  container_access_type = "private" # Private access only
}

# Virtual Network
resource "azurerm_virtual_network" "predictor" {
  name                = "vnet-crop-predictor"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.predictor.location
  resource_group_name = azurerm_resource_group.predictor.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.predictor.name
  virtual_network_name = azurerm_virtual_network.predictor.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# PostgreSQL database with secure configuration
resource "azurerm_postgresql_flexible_server" "predictions_db" {
  name                = "crop-predictions-db"
  resource_group_name = azurerm_resource_group.predictor.name
  location            = azurerm_resource_group.predictor.location
  version             = "15"

  # Authentication from Key Vault
  administrator_login    = "adminuser"
  administrator_password = azurerm_key_vault_secret.db_password.value

  storage_mb = 32768
  sku_name   = "GP_Standard_D2s_v3"

  # Network security
  public_network_access_enabled = false

  tags = {
    environment = "production"
    service     = "crop-yield-predictor"
  }
}

# Key Vault for secrets
resource "azurerm_key_vault" "secrets" {
  name                = "crop-predictor-kv"
  location            = azurerm_resource_group.predictor.location
  resource_group_name = azurerm_resource_group.predictor.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Network security
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      azurerm_subnet.aks_subnet.id
    ]
  }
}

data "azurerm_client_config" "current" {}

# Store database password in Key Vault
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.secrets.id
}

# Managed Identity
resource "azurerm_user_assigned_identity" "predictor" {
  name                = "crop-predictor-identity"
  resource_group_name = azurerm_resource_group.predictor.name
  location            = azurerm_resource_group.predictor.location
}

# Scoped role assignment (resource group level, not subscription)
resource "azurerm_role_assignment" "predictor_storage" {
  scope                = azurerm_storage_account.models.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.predictor.principal_id
}

resource "azurerm_role_assignment" "predictor_keyvault" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.predictor.principal_id
}

# Key Vault access policy
resource "azurerm_key_vault_access_policy" "predictor" {
  key_vault_id = azurerm_key_vault.secrets.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.predictor.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

data "azurerm_subscription" "current" {}
