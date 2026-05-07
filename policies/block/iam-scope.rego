package terraform.iam

# SEVERITY: BLOCK
# REASONING: Subscription-wide access violates least privilege
# BLAST RADIUS: Critical - access to all resources in subscription
# REVERSIBILITY: Medium - requires understanding service needs to scope properly

deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    contains(resource.scope, "subscription")
    resource.role_definition_name in ["Contributor", "Owner"]
    msg := sprintf(
        "Role assignment '%s' grants %s at subscription level.\n\nSecurity risk: Access to ALL resources.\n\nScope to resource:\nscope = azurerm_storage_account.example.id",
        [name, resource.role_definition_name]
    )
}