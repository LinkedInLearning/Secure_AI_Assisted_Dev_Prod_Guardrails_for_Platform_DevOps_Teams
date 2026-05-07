# RISKY: Reducing SKU or capacity in production

resource "azurerm_service_plan" "functions" {
  name                = "asp-teriana-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1" # CHANGED FROM: "P1v2" - significant downgrade
}

# Terraform plan output:
# azurerm_service_plan.functions will be updated in-place
# ~ sku_name = "P1v2" -> "B1"
# Performance degradation expected
