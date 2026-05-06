package terraform.iam

# BAD: Doesn't explain why or what to do
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Contributor"
    contains(resource.scope, "subscription")
    msg := "Invalid role assignment"
}