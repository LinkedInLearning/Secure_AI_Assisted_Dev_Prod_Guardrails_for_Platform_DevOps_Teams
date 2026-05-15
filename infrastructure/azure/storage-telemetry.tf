# Storage account for sensor telemetry data
# Added by: Platform Team
# Purpose: Store real-time sensor readings from field devices

resource "azurerm_storage_account" "sensor_telemetry" {
  name                     = "terianatelemetry"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable blob storage
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "production"
    purpose     = "sensor-telemetry"
    team        = "platform"
  }
}

# Container for raw sensor data
resource "azurerm_storage_container" "sensor_raw" {
  name                  = "sensor-raw"
  storage_account_name  = azurerm_storage_account.sensor_telemetry.name
  container_access_type = "private"
}

# Container for processed data
resource "azurerm_storage_container" "sensor_processed" {
  name                  = "sensor-processed"
  storage_account_name  = azurerm_storage_account.sensor_telemetry.name
  container_access_type = "private"
}
