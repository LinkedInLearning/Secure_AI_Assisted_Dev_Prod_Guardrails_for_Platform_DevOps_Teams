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
  skip_provider_registration = true
}

# Resource group for all Teriana Harvest resources
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    project     = "teriana-harvest"
    managed_by  = "terraform"
  }
}

# Storage account for sensor data
resource "azurerm_storage_account" "sensor_data" {
  name                     = "st${var.project_name}sensor${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    purpose     = "sensor-data-storage"
  }
}

# Service Bus namespace for event streaming
resource "azurerm_servicebus_namespace" "events" {
  name                = "sb-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = {
    environment = var.environment
    purpose     = "event-streaming"
  }
}

# Service Bus topic for sensor readings
resource "azurerm_servicebus_topic" "sensor_readings" {
  name                 = "sensor-readings"
  namespace_id         = azurerm_servicebus_namespace.events.id
  partitioning_enabled = true
}

# App Service Plan for function apps
resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# Function App for processing sensor data
resource "azurerm_linux_function_app" "sensor_processor" {
  name                = "func-${var.project_name}-processor-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.sensor_data.name
  storage_account_access_key = azurerm_storage_account.sensor_data.primary_access_key
  service_plan_id            = azurerm_service_plan.functions.id

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  tags = {
    environment = var.environment
    purpose     = "sensor-data-processing"
  }
}
