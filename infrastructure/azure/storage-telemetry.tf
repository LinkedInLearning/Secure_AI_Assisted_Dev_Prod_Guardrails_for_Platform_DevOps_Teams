# Storage account for sensor telemetry data
# Added by: Platform Team
# Purpose: Store real-time sensor readings from field devices

resource "azurerm_storage_account" "sensor_telemetry" {
  name                     = "terianatelemetry"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Network security: Deny public access by default
  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"

    # Allow access from Function App subnet
    virtual_network_subnet_ids = [
      azurerm_subnet.functions.id
    ]

    # Allow access from Azure services (for management)
    bypass = ["AzureServices"]
  }

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
