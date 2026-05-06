package terraform.iam

# GOOD: Explains the security issue and shows the fix
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Contributor"
    contains(resource.scope, "subscription")
    msg := sprintf(
        "Role assignment '%s' grants Contributor at subscription level.\n\nSecurity Issue: Grants access to ALL resources in the subscription.\n\nFix: Scope to specific resource:\nscope = azurerm_storage_account.example.id\n\nOr use specific role:\nrole_definition_name = 'Storage Blob Data Contributor'",
        [name]
    )
}