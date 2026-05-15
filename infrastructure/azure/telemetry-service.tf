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
  name                = "func-telemetry-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.telemetry.id

  # Use managed identity for storage access - no keys needed
  storage_account_name          = azurerm_storage_account.sensor_telemetry.name
  storage_uses_managed_identity = true

  site_config {
    application_stack {
      node_version = "18"
    }

    # Restrict CORS to known IoT gateway domains
    cors {
      allowed_origins = [
        "https://iot-gateway.teriana.com",
        "https://iot-gateway-staging.teriana.com"
      ]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "node"
    "STORAGE_ACCOUNT_NAME"           = azurerm_storage_account.sensor_telemetry.name
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
