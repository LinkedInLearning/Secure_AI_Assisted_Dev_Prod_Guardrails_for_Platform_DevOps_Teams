# BAD: Owner role allows principal to grant itself more permissions
resource "azurerm_role_assignment" "automation_account" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Owner" # DANGEROUS: Can modify role assignments
  principal_id         = azurerm_user_assigned_identity.automation.principal_id
}

# Automation only needs to start/stop VMs
# Owner allows it to create new role assignments and escalate privileges
