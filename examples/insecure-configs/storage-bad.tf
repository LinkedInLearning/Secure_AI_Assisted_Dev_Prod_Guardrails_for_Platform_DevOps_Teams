# BAD: Overly permissive, missing security settings
resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # DANGEROUS: No network rules restricting access
  # MISSING: min_tls_version
  # MISSING: encryption settings
}

# BAD: Overly broad permissions
resource "azurerm_role_assignment" "app_access" {
  scope                = azurerm_storage_account.sensor_data.id
  role_definition_name = "Contributor" # Too broad
  principal_id         = "dummy-principal-id"
}
