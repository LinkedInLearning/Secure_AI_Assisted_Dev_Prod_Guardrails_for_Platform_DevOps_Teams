# GOOD: Network access locked down
resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    ip_rules       = []
    virtual_network_subnet_ids = [
      azurerm_subnet.function_subnet.id
    ]
    bypass = ["AzureServices"]
  }
}

# Only accessible from specific subnet
# Default deny for everything else
