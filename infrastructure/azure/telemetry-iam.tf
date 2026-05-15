# IAM configuration for telemetry service
# Following principle of least privilege

# Grant storage-specific access using built-in role
resource "azurerm_role_assignment" "telemetry_storage_blob_contributor" {
  scope                = azurerm_storage_account.sensor_telemetry.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.telemetry_ingestion.identity[0].principal_id
}

# Data source for current subscription (for monitoring/logging only)
data "azurerm_subscription" "current" {}
