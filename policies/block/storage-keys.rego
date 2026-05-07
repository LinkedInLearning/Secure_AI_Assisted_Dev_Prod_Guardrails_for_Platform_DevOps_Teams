package terraform.auth

# SEVERITY: BLOCK
# REASONING: Storage keys cannot be scoped or safely rotated
# BLAST RADIUS: High - full access to storage account
# REVERSIBILITY: Medium - requires code changes to use managed identity

deny[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    setting := resource.app_settings[key]
    contains(lower(key), "connection_string")
    msg := sprintf(
        "Function app '%s' uses storage connection string.\n\nSecurity risk: Keys cannot be scoped or rotated safely.\n\nUse managed identity instead.",
        [name]
    )
}