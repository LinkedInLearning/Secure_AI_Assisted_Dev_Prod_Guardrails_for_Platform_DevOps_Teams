package terraform.auth

# Should this BLOCK or WARN?
deny[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    setting := resource.app_settings[key]
    contains(lower(key), "connection_string")
    msg := sprintf(
        "Function app '%s' uses storage connection string.\n\nSecurity risk: Keys cannot be scoped or rotated safely.\n\nUse managed identity instead.",
        [name]
    )
}