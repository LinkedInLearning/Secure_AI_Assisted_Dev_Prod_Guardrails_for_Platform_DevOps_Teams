# BAD: Wildcard scope grants access to entire subscription
resource "azurerm_role_assignment" "sensor_app" {
  scope                = data.azurerm_subscription.current.id # DANGEROUS: Subscription-wide
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.sensor_processor.identity[0].principal_id
}

# Sensor app only needs access to one storage account
# This grants access to ALL resources in the subscription
