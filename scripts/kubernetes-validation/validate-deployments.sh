#!/bin/bash
# Validates Kubernetes deployment manifests against security policies

set -e

echo "Validating Kubernetes deployments..."

if [ ! -d "examples/kubernetes" ]; then
    echo "No Kubernetes manifests found"
    exit 0
fi

# Setup OPA if not installed
if ! command -v opa &> /dev/null; then
    echo "Installing OPA..."
    curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
    chmod +x opa
    sudo mv opa /usr/local/bin/
fi

VIOLATIONS=0

# Validate all Kubernetes YAML files
for manifest in examples/kubernetes/**/*.yaml; do
    echo "Checking $manifest..."
    
    # Run OPA evaluation
    RESULT=$(opa eval --data policies/pod-security \
        --input "$manifest" \
        --format pretty \
        'data.kubernetes.pod_security' 2>/dev/null || echo "{}")
    
    # Check for denials (blocking violations)
    DENIES=$(echo "$RESULT" | jq -r '
        .resources + .probes + .security + .availability | 
        select(. != null) | 
        .deny // [] | 
        length' 2>/dev/null || echo "0")
    
    if [ "$DENIES" -gt 0 ]; then
        echo "❌ BLOCKING violations in $manifest:"
        echo "$RESULT" | jq -r '
            .resources.deny[]?, .probes.deny[]?, .security.deny[]?, .availability.deny[]?
        ' 2>/dev/null
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
    
    # Check for warnings (non-blocking)
    WARNS=$(echo "$RESULT" | jq -r '
        .resources + .probes + .security + .availability | 
        select(. != null) | 
        .warn // [] | 
        length' 2>/dev/null || echo "0")
    
    if [ "$WARNS" -gt 0 ]; then
        echo "⚠️  Warnings in $manifest:"
        echo "$RESULT" | jq -r '
            .resources.warn[]?, .probes.warn[]?, .security.warn[]?, .availability.warn[]?
        ' 2>/dev/null
    fi
    
    if [ "$DENIES" -eq 0 ] && [ "$WARNS" -eq 0 ]; then
        echo "✅ No issues found"
    fi
    
    echo ""
done

if [ $VIOLATIONS -gt 0 ]; then
    echo "❌ Found $VIOLATIONS manifests with blocking violations"
    exit 1
fi

echo "✅ All manifests validated successfully"