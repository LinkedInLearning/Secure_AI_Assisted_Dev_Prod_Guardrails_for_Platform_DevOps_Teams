#!/bin/bash
# Detects storage account keys in app settings

set -e

echo "Validating storage authentication methods..."

cd infrastructure/azure
terraform plan -out=tfplan.binary > /dev/null
terraform show -json tfplan.binary > tfplan.json

# Check for storage keys or connection strings in function app settings
KEY_USAGE=$(jq -r '
  .resource_changes[] |
  select(.type | IN("azurerm_linux_function_app", "azurerm_windows_function_app")) |
  select(.change.after.storage_account_access_key != null or
         (.change.after.app_settings | to_entries[] | 
          select(.key | test("CONNECTION_STRING|ACCESS_KEY"; "i")))) |
  {
    resource: .address,
    name: .change.after.name,
    issue: "Uses storage account keys instead of managed identity"
  }
' tfplan.json)

if [ ! -z "$KEY_USAGE" ]; then
  echo "❌ ERROR: Storage account keys detected in function app configuration"
  echo ""
  echo "$KEY_USAGE" | jq -r '"  Resource: \(.resource)\n  Name: \(.name)\n  Issue: \(.issue)\n"'
  echo "SECURITY VIOLATION: Use managed identity for storage access."
  echo "Set storage_uses_managed_identity = true and grant Storage Blob Data Contributor role."
  exit 1
fi

echo "✅ No storage account keys in app settings"