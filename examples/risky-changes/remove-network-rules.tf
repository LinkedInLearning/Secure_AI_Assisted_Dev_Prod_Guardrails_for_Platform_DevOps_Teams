# RISKY: Removing network restrictions opens security hole

resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # REMOVED: network_rules block
  # Storage account now accessible from internet
}

# Terraform plan output:
# azurerm_storage_account.sensor_data will be updated in-place
# - network_rules {
#     - default_action = "Deny"
#   }
