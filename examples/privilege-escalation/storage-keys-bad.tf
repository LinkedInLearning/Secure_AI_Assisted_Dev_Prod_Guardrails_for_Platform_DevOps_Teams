# BAD: Using storage account keys instead of managed identity
resource "azurerm_linux_function_app" "sensor_processor" {
  name                 = "func-sensor-processor"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  service_plan_id      = azurerm_service_plan.functions.id
  storage_account_name = azurerm_storage_account.sensor_data.name

  # DANGEROUS: Access keys in app settings
  app_settings = {
    "STORAGE_CONNECTION_STRING" = azurerm_storage_account.sensor_data.primary_connection_string
  }

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  # Should use managed identity instead
}

# Storage keys grant full access to storage account
# Can't be rotated without updating all apps
# Can't be scoped to specific containers
