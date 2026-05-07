# RISKY: Deletes production storage account
# This change removes the storage account resource entirely
# Terraform will destroy the resource and all data

# BEFORE (in main):
# resource "azurerm_storage_account" "sensor_data" {
#   name                     = "terianasensor"
#   resource_group_name      = azurerm_resource_group.main.name
#   location                 = azurerm_resource_group.main.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# AFTER (in this PR):
# Resource removed - will be DESTROYED

# Terraform plan output:
# azurerm_storage_account.sensor_data will be destroyed
