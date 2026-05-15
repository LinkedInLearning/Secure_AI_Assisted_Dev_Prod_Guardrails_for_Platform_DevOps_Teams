# Terraform Network Security - AI Guidance

## Context
This guidance was generated after detecting 34 instances where AI-generated Terraform created storage accounts without network restrictions, exposing data to the internet.

## The Problem We Saw

AI tools frequently generate Azure storage accounts like this:

````hcl
# ❌ No network restrictions (blocked by guardrails 34 times)
resource "azurerm_storage_account" "data" {
  name                     = "companydatastore"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
````

**Why this fails:** Default network access is "Allow from all networks" - your data is exposed to the internet.

## Always Restrict Network Access

When generating Azure storage accounts, ALWAYS include network rules:

````hcl
# ✅ Correct (guardrail will pass)
resource "azurerm_storage_account" "data" {
  name                     = "companydatastore"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Network security
  public_network_access_enabled = false
  
  network_rules {
    default_action = "Deny"
    ip_rules       = []  # Add specific IPs if needed
    virtual_network_subnet_ids = [
      azurerm_subnet.private.id
    ]
  }
}
````

## Network Security Patterns

### Pattern 1: Private VNet Access Only (Recommended)
````hcl
network_rules {
  default_action = "Deny"
  virtual_network_subnet_ids = [
    azurerm_subnet.app_subnet.id
  ]
}
````

### Pattern 2: Specific IP Allowlist
````hcl
network_rules {
  default_action = "Deny"
  ip_rules       = ["203.0.113.0/24"]  # Office IP range
  virtual_network_subnet_ids = [
    azurerm_subnet.app_subnet.id
  ]
}
````

### Pattern 3: Completely Private (No Public Access)
````hcl
public_network_access_enabled = false

network_rules {
  default_action = "Deny"
  virtual_network_subnet_ids = [
    azurerm_subnet.private.id
  ]
}
````

## Why This Matters

**Before guidance:** 34 failures in 30 days
**After guidance:** 4 failures in 30 days
**Reduction:** 88% fewer failures

## When You See This Error
```
Guardrail failed: Storage account missing network restrictions
```

Add the network_rules block with default_action = "Deny" and specify allowed virtual networks or IPs.