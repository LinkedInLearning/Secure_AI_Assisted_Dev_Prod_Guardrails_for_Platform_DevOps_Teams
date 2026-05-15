# IAM configuration for telemetry service
# The service needs to write sensor data to storage

# Grant the function app access to Azure subscription
# TODO: This might be too broad, but it simplifies management
# We can scope it down later if needed
resource "azurerm_role_assignment" "telemetry_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.telemetry_ingestion.identity[0].principal_id
}

# Data source for current subscription
data "azurerm_subscription" "current" {}
