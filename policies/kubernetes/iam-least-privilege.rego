package terraform.iam

# Deny wildcard actions in IAM policies
deny[msg] {
    resource := input.resource.azurerm_role_assignment[_]
    resource.role_definition_name == "Contributor"
    msg := "Role 'Contributor' grants excessive permissions - use specific roles"
}

# Deny storage account public access
deny[msg] {
    resource := input.resource.azurerm_storage_account[_]
    resource.allow_blob_public_access == true
    msg := sprintf("Storage account '%s' allows public blob access", [resource.name])
}