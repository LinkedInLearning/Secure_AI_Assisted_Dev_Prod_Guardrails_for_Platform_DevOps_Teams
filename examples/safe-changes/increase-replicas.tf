# SAFE: Increasing capacity improves reliability

resource "azurerm_service_plan" "functions" {
  name                = "asp-teriana-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "P2v2" # CHANGED FROM: "P1v2" - upgrade
}

# Terraform plan output:
# azurerm_service_plan.functions will be updated in-place
# ~ sku_name = "P1v2" -> "P2v2"
# Performance improvement expected
