package terraform.privilege

import future.keywords.in

# Deny subscription-level role assignments for application identities
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    contains(resource.scope, "subscription")
    resource.role_definition_name in ["Contributor", "Owner", "Reader"]
    msg := sprintf("Role assignment '%s' grants %s at subscription level - scope to resource group or resource", 
                   [name, resource.role_definition_name])
}

# Warn on resource group level Contributor/Owner
warn[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    contains(resource.scope, "resourceGroups")
    resource.role_definition_name in ["Contributor", "Owner"]
    msg := sprintf("Role assignment '%s' grants %s at resource group level - consider scoping to specific resource", 
                   [name, resource.role_definition_name])
}