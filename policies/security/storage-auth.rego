package terraform.security.auth

# POLICY: Block storage account keys in function apps
# SEVERITY: HIGH
# REASONING: Keys can't be scoped or safely rotated

deny[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    resource.storage_account_access_key
    
    msg := sprintf(
        "BLOCKED: Function app '%s' uses storage_account_access_key.\n\nSecurity risk: Keys cannot be scoped or rotated safely.\n\nUse managed identity:\nstorage_uses_managed_identity = true\n\nGrant role:\nazurerm_role_assignment {\n  scope = azurerm_storage_account.example.id\n  role_definition_name = \"Storage Blob Data Contributor\"\n}",
        [name]
    )
}

warn[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    setting := resource.app_settings[key]
    contains(lower(key), "connection_string")
    
    msg := sprintf(
        "WARNING: Function app '%s' has CONNECTION_STRING in app_settings.\n\nBest practice: Use managed identity instead of connection strings.",
        [name]
    )
}