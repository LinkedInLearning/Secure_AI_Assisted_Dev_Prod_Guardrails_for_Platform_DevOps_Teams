package terraform.security.network

# POLICY: Block storage accounts without network restrictions
# SEVERITY: CRITICAL
# REASONING: Exposes data to public internet

deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    not resource.network_rules
    
    msg := sprintf(
        "BLOCKED: Storage account '%s' missing network_rules.\n\nSecurity risk: Accessible from public internet.\n\nAdd:\nnetwork_rules {\n  default_action = \"Deny\"\n  virtual_network_subnet_ids = [azurerm_subnet.example.id]\n}",
        [name]
    )
}

deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    resource.public_network_access_enabled == true
    
    msg := sprintf(
        "BLOCKED: Storage account '%s' has public_network_access_enabled = true.\n\nSecurity risk: Bypasses network_rules restrictions.\n\nSet: public_network_access_enabled = false",
        [name]
    )
}