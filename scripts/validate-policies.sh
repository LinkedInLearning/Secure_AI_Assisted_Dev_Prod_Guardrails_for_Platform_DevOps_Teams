#!/bin/bash

# Validate Kubernetes manifests against OPA policies
echo "Validating Kubernetes configurations..."

for file in examples/insecure-configs/*.yaml; do
    echo "Checking $file (should fail)..."
    opa eval -d policies/kubernetes -i "$file" "data.kubernetes.resourcelimits.deny" --format pretty
    opa eval -d policies/kubernetes -i "$file" "data.kubernetes.healthprobes.deny" --format pretty
done

for file in examples/secure-configs/*.yaml; do
    echo "Checking $file (should pass)..."
    opa eval -d policies/kubernetes -i "$file" "data.kubernetes.resourcelimits.deny" --format pretty
    opa eval -d policies/kubernetes -i "$file" "data.kubernetes.healthprobes.deny" --format pretty
done

echo "Validation complete!"