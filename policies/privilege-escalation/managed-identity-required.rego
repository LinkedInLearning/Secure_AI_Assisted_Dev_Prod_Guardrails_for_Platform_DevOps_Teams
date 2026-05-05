package terraform.privilege

# Deny storage account keys in app settings
deny[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    setting := resource.app_settings[key]
    contains(lower(key), "connection_string")
    contains(lower(setting), "accountkey")
    msg := sprintf("Function app '%s' uses storage account keys - use managed identity instead", [name])
}

# Require managed identity on function apps
deny[msg] {
    resource := input.resource.azurerm_linux_function_app[name]
    not resource.identity
    msg := sprintf("Function app '%s' missing managed identity", [name])
}