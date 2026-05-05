package terraform.privilege

# Deny storage accounts without network rules
deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    not resource.network_rules
    msg := sprintf("Storage account '%s' missing network_rules - default allows public access", [name])
}

# Deny default_action = Allow
deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    resource.network_rules.default_action == "Allow"
    msg := sprintf("Storage account '%s' network_rules default_action is Allow - should be Deny", [name])
}