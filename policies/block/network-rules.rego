package terraform.storage

# SEVERITY: BLOCK
# REASONING: Public access creates attack surface
# BLAST RADIUS: High - data accessible from internet
# REVERSIBILITY: Easy - network rules can be added post-deployment

deny[msg] {
    resource := input.resource.azurerm_storage_account[name]
    not resource.network_rules
    msg := sprintf(
        "Storage account '%s' missing network_rules.\n\nSecurity risk: Accessible from internet by default.",
        [name]
    )
}