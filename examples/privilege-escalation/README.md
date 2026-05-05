# Privilege Escalation Examples

This directory contains examples of privilege escalation patterns in AI-generated Terraform code and the policy rules that catch them.

## Attack Patterns

### 1. Wildcard Scope (`wildcard-permissions-bad.tf`)
Grants access at subscription or resource group level when resource-level would suffice.

### 2. Owner Role Assignment (`owner-role-bad.tf`)
Grants Owner role which allows the principal to modify role assignments and escalate privileges.

### 3. Storage Account Keys (`storage-keys-bad.tf`)
Uses connection strings with account keys instead of managed identities.

### 4. Missing Network Rules (`network-bypass-bad.tf`)
Storage accounts accessible from anywhere instead of restricted to specific networks.

## Secure Patterns

### 1. Scoped Permissions (`scoped-permissions-good.tf`)
Role assignments scoped to specific resources with minimal required permissions.

### 2. Managed Identity (`managed-identity-good.tf`)
Uses system-assigned managed identities instead of connection strings.

### 3. Network Restrictions (`network-restricted-good.tf`)
Storage accounts with network rules that deny by default and allow specific subnets.

## Policy Rules

All policies are in `policies/privilege-escalation/`:
- `scope-validation.rego` - Validates role assignment scopes
- `owner-role-prevention.rego` - Blocks Owner/Contributor at broad scopes
- `managed-identity-required.rego` - Requires managed identities
- `network-restrictions.rego` - Enforces network rules on storage accounts