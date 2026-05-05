# GOOD: Minimal scope, specific role
resource "azurerm_role_assignment" "sensor_app" {
  scope                = azurerm_storage_account.sensor_data.id # Resource-level
  role_definition_name = "Storage Blob Data Contributor"        # Specific permission
  principal_id         = azurerm_linux_function_app.sensor_processor.identity[0].principal_id
}

# Grants access ONLY to this storage account
# Grants ONLY blob operations, not account management
