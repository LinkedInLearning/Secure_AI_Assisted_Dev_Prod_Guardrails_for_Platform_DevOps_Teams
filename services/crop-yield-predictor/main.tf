# AI-generated Terraform infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "predictor" {
  name     = "rg-crop-predictor-prod"
  location = "East US"
}

# Storage account for ML models
resource "azurerm_storage_account" "models" {
  name                     = "cropmodelstorage"
  resource_group_name      = azurerm_resource_group.predictor.name
  location                 = azurerm_resource_group.predictor.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # AI didn't add network restrictions
}

resource "azurerm_storage_container" "models" {
  name                  = "ml-models"
  storage_account_name  = azurerm_storage_account.models.name
  container_access_type = "blob" # Public access!
}

# PostgreSQL database
resource "azurerm_postgresql_flexible_server" "predictions_db" {
  name                   = "crop-predictions-db"
  resource_group_name    = azurerm_resource_group.predictor.name
  location               = azurerm_resource_group.predictor.location
  version                = "15"
  administrator_login    = "adminuser"
  administrator_password = "P@ssw0rd123!" # Hardcoded password!

  storage_mb = 32768
  sku_name   = "GP_Standard_D2s_v3"
}

# Key Vault
resource "azurerm_key_vault" "secrets" {
  name                = "crop-predictor-kv"
  location            = azurerm_resource_group.predictor.location
  resource_group_name = azurerm_resource_group.predictor.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

data "azurerm_client_config" "current" {}

# Managed Identity
resource "azurerm_user_assigned_identity" "predictor" {
  name                = "crop-predictor-identity"
  resource_group_name = azurerm_resource_group.predictor.name
  location            = azurerm_resource_group.predictor.location
}

# Overly permissive role assignment
resource "azurerm_role_assignment" "predictor_contributor" {
  scope                = data.azurerm_subscription.current.id # Subscription-wide!
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.predictor.principal_id
}

data "azurerm_subscription" "current" {}
