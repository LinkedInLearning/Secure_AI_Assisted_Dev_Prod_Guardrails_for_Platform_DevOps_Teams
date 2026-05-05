# BAD: Service can access storage from anywhere
resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # DANGEROUS: No network restrictions
  # Missing network_rules block entirely
  # Default action is "Allow"
}

# Any compromised service anywhere can access this storage
