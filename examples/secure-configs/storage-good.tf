# GOOD: Locked down, specific permissions
resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Secure: Network rules restrict access
  network_rules {
    default_action = "Deny"
    ip_rules       = ["10.0.0.0/16"]
  }

  # Secure: TLS enforced
  min_tls_version = "TLS1_2"
}

# GOOD: Specific permissions only
resource "azurerm_role_assignment" "app_access" {
  scope                = azurerm_storage_account.sensor_data.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = "dummy-principal-id"
}
