#!/bin/bash
# Fast rollback script for emergency situations
# Bypasses normal checks and immediately rolls back

set -e

ROLLOUT_NAME="${1:-sensor-data-api}"
NAMESPACE="${2:-production}"

echo "========================================="
echo "EMERGENCY FAST ROLLBACK"
echo "Rollout: $ROLLOUT_NAME"
echo "Namespace: $NAMESPACE"
echo "========================================="
echo ""

# Confirm
read -p "This will immediately rollback to stable. Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled"
    exit 0
fi

echo "1. Aborting current rollout..."
kubectl argo rollouts abort $ROLLOUT_NAME -n $NAMESPACE

echo "2. Setting canary weight to 0%..."
kubectl argo rollouts set canary $ROLLOUT_NAME --weight 0 -n $NAMESPACE

echo "3. Promoting stable version..."
kubectl argo rollouts promote $ROLLOUT_NAME -n $NAMESPACE --full

echo ""
echo "✅ Fast rollback complete"
echo ""
echo "Current status:"
kubectl argo rollouts status $ROLLOUT_NAME -n $NAMESPACE