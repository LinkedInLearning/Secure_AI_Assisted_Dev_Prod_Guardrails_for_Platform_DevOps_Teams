#!/bin/bash
# Detects configuration changes that could break existing deployments

set -e

echo "Checking for breaking configuration changes..."

cd infrastructure/azure
terraform plan -out=tfplan.binary > /dev/null
terraform show -json tfplan.binary > tfplan.json

# Check for region changes
REGION_CHANGES=$(jq '[.resource_changes[] | select(.change.after.location != .change.before.location)] | length' tfplan.json 2>/dev/null || echo 0)

if [ "$REGION_CHANGES" -gt 0 ]; then
    echo "❌ ERROR: Region change detected"
    jq -r '.resource_changes[] | select(.change.after.location != .change.before.location) | "  \(.address): \(.change.before.location) -> \(.change.after.location)"' tfplan.json
    echo ""
    echo "Changing regions requires resource recreation and data migration."
    exit 1
fi

# Check for network rule removals
NETWORK_REMOVALS=$(jq '[.resource_changes[] | select(.type == "azurerm_storage_account" and .change.before.network_rules != null and .change.after.network_rules == null)] | length' tfplan.json 2>/dev/null || echo 0)

if [ "$NETWORK_REMOVALS" -gt 0 ]; then
    echo "❌ ERROR: Network rules being removed from storage account"
    echo ""
    echo "This exposes storage to public internet access."
    exit 1
fi

# Check for SKU downgrades
jq -r '.resource_changes[] | select(.change.after.sku_name != null and .change.before.sku_name != null) | select(.change.after.sku_name < .change.before.sku_name) | .address' tfplan.json > /tmp/downgrades.txt 2>/dev/null || true

if [ -s /tmp/downgrades.txt ]; then
    echo "⚠️  WARNING: SKU downgrade detected"
    cat /tmp/downgrades.txt
    echo ""
    echo "Downgrading may impact performance or availability."
fi

echo "✅ No breaking changes detected"