#!/bin/bash
# Detects storage accounts without network restrictions

set -e

echo "Validating storage account network rules..."

cd infrastructure/azure
terraform plan -out=tfplan.binary > /dev/null
terraform show -json tfplan.binary > tfplan.json

# Check for storage accounts without network rules
OPEN_STORAGE=$(jq -r '
  .resource_changes[] |
  select(.type == "azurerm_storage_account") |
  select(.change.after.network_rules == null or 
         .change.after.network_rules == [] or
         .change.after.public_network_access_enabled == true) |
  {
    resource: .address,
    name: .change.after.name,
    public_access: .change.after.public_network_access_enabled
  }
' tfplan.json)

if [ ! -z "$OPEN_STORAGE" ]; then
  echo "❌ ERROR: Storage accounts without network restrictions detected"
  echo ""
  echo "$OPEN_STORAGE" | jq -r '"  Resource: \(.resource)\n  Name: \(.name)\n  Public Access: \(.public_access)\n"'
  echo "SECURITY VIOLATION: Storage accounts must have network_rules configured."
  echo "Set default_action = \"Deny\" and specify allowed subnets/IPs."
  exit 1
fi

echo "✅ All storage accounts have network restrictions"