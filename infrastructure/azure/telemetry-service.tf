# Azure Function App for ingesting sensor telemetry
# Receives data from IoT devices and writes to storage

resource "azurerm_service_plan" "telemetry" {
  name                = "asp-telemetry-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "P1v2"

  tags = {
    environment = "production"
    service     = "telemetry-ingestion"
  }
}

resource "azurerm_linux_function_app" "telemetry_ingestion" {
  name                       = "func-telemetry-prod"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.telemetry.id
  storage_account_name       = azurerm_storage_account.sensor_telemetry.name
  storage_account_access_key = azurerm_storage_account.sensor_telemetry.primary_access_key

  site_config {
    application_stack {
      node_version = "18"
    }

    # CORS configuration for IoT devices
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "STORAGE_CONNECTION_STRING"      = azurerm_storage_account.sensor_telemetry.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
    service     = "telemetry-ingestion"
  }
}
