package terraform.security.iam

# POLICY: Block subscription-level privileged role assignments
# SEVERITY: CRITICAL
# REASONING: Violates least privilege, massive blast radius

deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    contains(resource.scope, "/subscriptions/")
    count(split(resource.scope, "/")) == 3
    resource.role_definition_name in ["Owner", "Contributor", "User Access Administrator"]
    
    msg := sprintf(
        "BLOCKED: Role assignment '%s' grants %s at subscription level.\n\nSecurity risk: Access to ALL resources in subscription.\n\nScope to specific resource:\nscope = azurerm_storage_account.example.id\n\nRole: %s\nScope: %s",
        [name, resource.role_definition_name, resource.role_definition_name, resource.scope]
    )
} 