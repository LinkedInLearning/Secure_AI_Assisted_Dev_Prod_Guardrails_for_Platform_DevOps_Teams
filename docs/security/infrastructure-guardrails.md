# Infrastructure Security Guardrails

This document describes the security controls that prevent dangerous infrastructure changes from reaching production.

## Defense Layers

### Layer 1: Automated Detection (CI Pipeline)
Scripts that analyze Terraform plans and block PRs with security violations.

**IAM Scope Validation** (`validate-iam-scope.sh`)
- Detects subscription-level role assignments
- Blocks: Owner, Contributor, User Access Administrator at subscription scope
- Requires: Resource-level scoping

**Network Rules Validation** (`validate-network-rules.sh`)
- Detects storage accounts without network restrictions
- Blocks: Missing `network_rules` or `public_network_access_enabled = true`
- Requires: `default_action = "Deny"` with explicit subnet allowlist

**Storage Authentication Validation** (`validate-storage-auth.sh`)
- Detects storage account keys in function app configuration
- Blocks: `storage_account_access_key` or connection strings in app_settings
- Requires: `storage_uses_managed_identity = true`

### Layer 2: Policy-as-Code (OPA)
Rego policies that enforce security patterns.

**iam-scope.rego**
```rego
Blocks: Subscription-level privileged roles
Severity: CRITICAL
Message: Includes specific resource scoping example
```

**network-rules.rego**
```rego
Blocks: Storage accounts without network_rules
Severity: CRITICAL
Message: Includes network_rules configuration example
```

**storage-auth.rego**
```rego
Blocks: Storage keys in function apps
Severity: HIGH
Message: Includes managed identity configuration example
```

### Layer 3: Approval Gates (GitHub Environments)
Risk-based approval requirements.

**Critical Changes** (IAM, data resources, network restrictions)
- Required approvers: Security Team Lead + Platform Manager
- Prevent self-approval: Enabled
- Custom protection rule: Observability gate

**Standard Changes** (configuration, scaling)
- Required approvers: 1 Platform Engineer
- No wait timer

## How the Incident Would Have Been Prevented

### Original Dangerous Code

**Problem 1: Subscription-wide Contributor**
```hcl
resource "azurerm_role_assignment" "telemetry_contributor" {
  scope                = data.azurerm_subscription.current.id  # ❌
  role_definition_name = "Contributor"
  ...
}
```

**Caught by:**
- ✅ `validate-iam-scope.sh` - Detects subscription-level scope
- ✅ `iam-scope.rego` - Blocks privileged subscription roles
- ✅ Approval gate - Requires security team review

**Fixed:**
```hcl
resource "azurerm_role_assignment" "telemetry_storage_blob_contributor" {
  scope                = azurerm_storage_account.sensor_telemetry.id  # ✅
  role_definition_name = "Storage Blob Data Contributor"
  ...
}
```

**Problem 2: No Network Restrictions**
```hcl
resource "azurerm_storage_account" "sensor_telemetry" {
  name = "terianatelemetry"
  # ❌ No network_rules
  # ❌ Public access enabled by default
}
```

**Caught by:**
- ✅ `validate-network-rules.sh` - Detects missing network_rules
- ✅ `network-rules.rego` - Blocks public storage accounts
- ✅ Approval gate - Requires security team review

**Fixed:**
```hcl
resource "azurerm_storage_account" "sensor_telemetry" {
  name = "terianatelemetry"
  public_network_access_enabled = false  # ✅
  
  network_rules {
    default_action = "Deny"  # ✅
    virtual_network_subnet_ids = [azurerm_subnet.functions.id]
  }
}
```

**Problem 3: Storage Keys in App Settings**
```hcl
resource "azurerm_linux_function_app" "telemetry_ingestion" {
  storage_account_access_key = azurerm_storage_account.sensor_telemetry.primary_access_key  # ❌
  
  app_settings = {
    "STORAGE_CONNECTION_STRING" = azurerm_storage_account.sensor_telemetry.primary_connection_string  # ❌
  }
}
```

**Caught by:**
- ✅ `validate-storage-auth.sh` - Detects keys in configuration
- ✅ `storage-auth.rego` - Blocks storage key usage

**Fixed:**
```hcl
resource "azurerm_linux_function_app" "telemetry_ingestion" {
  storage_uses_managed_identity = true  # ✅
  
  app_settings = {
    "STORAGE_ACCOUNT_NAME" = azurerm_storage_account.sensor_telemetry.name  # ✅
  }
}
```

## Control Effectiveness

| Control | Detection Time | Block Point | False Positive Rate |
|---------|---------------|-------------|---------------------|
| IAM Scope Validation | PR creation | CI pipeline | Low |
| Network Rules Validation | PR creation | CI pipeline | Low |
| Storage Auth Validation | PR creation | CI pipeline | Low |
| OPA Policies | PR creation | CI pipeline | Very Low |
| Approval Gates | Pre-deployment | GitHub Environment | N/A |

## Exception Process

**When legitimate exceptions needed:**
1. Document justification in PR description
2. Create security review ticket
3. Request exception from Security Team Lead
4. Approval recorded in audit trail
5. Temporary exception expires after 30 days

**Example legitimate exceptions:**
- Storage account needs temporary public access for migration
- Service needs broader permissions during initial deployment
- Emergency incident response requires elevated access

All exceptions reviewed monthly by security team.