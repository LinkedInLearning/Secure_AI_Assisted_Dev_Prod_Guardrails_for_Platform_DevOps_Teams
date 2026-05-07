package terraform.storage

# Should this BLOCK or WARN?
deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    not resource.network_rules
    msg := sprintf(
        "Storage account '%s' missing network_rules.\n\nSecurity risk: Accessible from internet by default.",
        [name]
    )
}