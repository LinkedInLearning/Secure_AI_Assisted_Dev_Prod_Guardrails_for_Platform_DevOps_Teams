package terraform.iam

# Should this BLOCK or WARN?
deny[msg] {
    resource := input.resource.azurerm_role_assignment[name]
    resource.role_definition_name == "Owner"
    msg := sprintf(
        "Role assignment '%s' grants Owner role.\n\nSecurity risk: Allows privilege escalation via role modifications.",
        [name]
    )
}