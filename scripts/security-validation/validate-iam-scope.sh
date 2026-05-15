#!/bin/bash
# Detects overly broad IAM role assignments

set -e

echo "Validating IAM role scopes..."

cd infrastructure/azure
terraform plan -out=tfplan.binary > /dev/null
terraform show -json tfplan.binary > tfplan.json

# Check for subscription-level role assignments
SUBSCRIPTION_ROLES=$(jq -r '
  .resource_changes[] | 
  select(.type == "azurerm_role_assignment") |
  select(.change.after.scope | contains("/subscriptions/") and 
         (. | split("/") | length) == 3) |
  select(.change.after.role_definition_name | 
         IN("Owner", "Contributor", "User Access Administrator")) |
  {
    resource: .address,
    role: .change.after.role_definition_name,
    scope: .change.after.scope
  }
' tfplan.json)

if [ ! -z "$SUBSCRIPTION_ROLES" ]; then
  echo "❌ ERROR: Subscription-level privileged role assignments detected"
  echo ""
  echo "$SUBSCRIPTION_ROLES" | jq -r '"  Resource: \(.resource)\n  Role: \(.role)\n  Scope: \(.scope)\n"'
  echo "SECURITY VIOLATION: Role assignments must be scoped to specific resources."
  echo "Use resource-level scoping: azurerm_storage_account.example.id"
  exit 1
fi

echo "✅ No subscription-level privileged role assignments detected"