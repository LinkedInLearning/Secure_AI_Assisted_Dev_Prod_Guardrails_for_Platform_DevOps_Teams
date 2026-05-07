# SAFE: Adding tags doesn't affect functionality

resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
    team        = "platform"
    cost-center = "engineering" # NEW
  }
}

# Terraform plan output:
# azurerm_storage_account.sensor_data will be updated in-place
# + tags = { cost-center = "engineering" }
