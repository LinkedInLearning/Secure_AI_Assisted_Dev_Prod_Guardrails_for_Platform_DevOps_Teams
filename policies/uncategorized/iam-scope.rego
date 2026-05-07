package terraform.iam

# Should this BLOCK or WARN?
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    contains(resource.scope, "subscription")
    resource.role_definition_name in ["Contributor", "Owner"]
    msg := sprintf(
        "Role assignment '%s' grants %s at subscription level.\n\nSecurity risk: Access to ALL resources.\n\nScope to resource:\nscope = azurerm_storage_account.example.id",
        [name, resource.role_definition_name]
    )
}