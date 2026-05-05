# GOOD: Managed identity instead of storage keys
resource "azurerm_linux_function_app" "sensor_processor" {
  name                 = "func-sensor-processor"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  service_plan_id      = azurerm_service_plan.functions.id
  storage_account_name = azurerm_storage_account.sensor_data.name

  identity {
    type = "SystemAssigned" # Managed identity enabled
  }

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  # No storage keys in app settings
  # Access controlled via role assignment
}

resource "azurerm_role_assignment" "function_storage" {
  scope                = azurerm_storage_account.sensor_data.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.sensor_processor.identity[0].principal_id
}
