package terraform.iam

# SEVERITY: BLOCK
# REASONING: Owner role allows privilege escalation
# BLAST RADIUS: Critical - compromised identity can grant itself any permission
# REVERSIBILITY: Hard - requires security review and audit

deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Owner"
    msg := sprintf(
        "Role assignment '%s' grants Owner role.\n\nSecurity risk: Allows privilege escalation via role modifications.",
        [name]
    )
}