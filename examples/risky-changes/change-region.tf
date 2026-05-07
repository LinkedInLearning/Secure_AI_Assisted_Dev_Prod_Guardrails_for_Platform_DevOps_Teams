# RISKY: Changing region requires resource replacement
# This forces Terraform to destroy and recreate the resource

resource "azurerm_storage_account" "sensor_data" {
  name                     = "terianasensor"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "westus" # CHANGED FROM: "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Terraform plan output:
# azurerm_storage_account.sensor_data must be replaced
# -/+ destroy and then create replacement
