#!/bin/bash
# Analyzes Terraform plan for resource destruction

set -e

echo "Analyzing Terraform plan for risky operations..."

# Generate plan in JSON format
cd infrastructure/azure
terraform plan -out=tfplan.binary > /dev/null
terraform show -json tfplan.binary > tfplan.json

# Check for resource deletions
DESTROYS=$(jq '[.resource_changes[] | select(.change.actions[] == "delete")] | length' tfplan.json)

if [ "$DESTROYS" -gt 0 ]; then
    echo "❌ ERROR: Plan contains $DESTROYS resource deletion(s)"
    echo ""
    echo "Resources to be destroyed:"
    jq -r '.resource_changes[] | select(.change.actions[] == "delete") | "  - \(.address) (\(.type))"' tfplan.json
    echo ""
    echo "Resource deletion requires manual approval."
    exit 1
fi

# Check for replace operations
REPLACES=$(jq '[.resource_changes[] | select(.change.actions[] == "delete" and .change.actions[] == "create")] | length' tfplan.json)

if [ "$REPLACES" -gt 0 ]; then
    echo "⚠️  WARNING: Plan contains $REPLACES resource replacement(s)"
    echo ""
    echo "Resources to be replaced:"
    jq -r '.resource_changes[] | select(.change.actions[] == "delete" and .change.actions[] == "create") | "  - \(.address) (\(.type))"' tfplan.json
    echo ""
    echo "Replacements may cause downtime. Review carefully."
fi

echo "✅ No resource deletions detected"