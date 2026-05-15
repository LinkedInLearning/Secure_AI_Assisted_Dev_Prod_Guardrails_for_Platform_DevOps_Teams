#!/bin/bash
# Validates Kubernetes manifests against reliability policies

set -e

echo "Validating deployment reliability..."

MANIFEST="${1:-deployments/data-aggregator.yaml}"

if [ ! -f "$MANIFEST" ]; then
    echo "Error: Manifest not found: $MANIFEST"
    exit 1
fi

echo "Checking: $MANIFEST"
echo ""

# Run OPA evaluation
RESULT=$(opa eval --data policies/reliability \
    --input "$MANIFEST" \
    --format pretty \
    'data.kubernetes.reliability' 2>/dev/null || echo "{}")

# Check for blocking violations
DENIES=$(echo "$RESULT" | jq -r '
    .resources.deny // [] + 
    .probes.deny // [] + 
    .security.deny // [] + 
    .availability.deny // [] | 
    length' 2>/dev/null || echo "0")

if [ "$DENIES" -gt 0 ]; then
    echo "❌ BLOCKING VIOLATIONS:"
    echo ""
    echo "$RESULT" | jq -r '
        .resources.deny[]?, 
        .probes.deny[]?, 
        .security.deny[]?, 
        .availability.deny[]?
    ' 2>/dev/null | while read -r line; do
        echo "$line"
        echo ""
    done
    echo "Deployment BLOCKED. Fix violations before deploying to production."
    exit 1
fi

# Check for warnings
WARNS=$(echo "$RESULT" | jq -r '
    .resources.warn // [] + 
    .probes.warn // [] + 
    .security.warn // [] + 
    .availability.warn // [] | 
    length' 2>/dev/null || echo "0")

if [ "$WARNS" -gt 0 ]; then
    echo "⚠️  WARNINGS:"
    echo ""
    echo "$RESULT" | jq -r '
        .resources.warn[]?, 
        .probes.warn[]?, 
        .security.warn[]?, 
        .availability.warn[]?
    ' 2>/dev/null | while read -r line; do
        echo "$line"
        echo ""
    done
    echo "Warnings do not block deployment but should be addressed for production readiness."
fi

if [ "$DENIES" -eq 0 ] && [ "$WARNS" -eq 0 ]; then
    echo "✅ All reliability checks passed!"
fi

echo ""
echo "Summary:"
echo "  Blocking violations: $DENIES"
echo "  Warnings: $WARNS"

exit 0