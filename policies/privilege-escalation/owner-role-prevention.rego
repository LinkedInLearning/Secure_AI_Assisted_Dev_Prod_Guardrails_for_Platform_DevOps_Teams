package terraform.privilege

# Deny Owner role assignments (can modify role assignments)
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Owner"
    msg := sprintf("Role assignment '%s' grants Owner role - this allows privilege escalation", [name])
}

# Deny Contributor role at subscription level
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Contributor"
    contains(resource.scope, "subscription")
    msg := sprintf("Role assignment '%s' grants Contributor at subscription level - too broad", [name])
}