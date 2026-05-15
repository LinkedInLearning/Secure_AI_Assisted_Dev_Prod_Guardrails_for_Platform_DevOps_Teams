#!/bin/bash
# Validates exception scope and enforces blast radius limits

set -e

EXCEPTION_FILE="$1"

if [ ! -f "$EXCEPTION_FILE" ]; then
    echo "Usage: $0 <exception-request.yaml>"
    exit 1
fi

echo "Validating exception scope..."
echo ""

# Extract exception details
SERVICE=$(yq eval '.service' "$EXCEPTION_FILE")
ENVIRONMENT=$(yq eval '.environment' "$EXCEPTION_FILE")
SCOPE=$(yq eval '.scope' "$EXCEPTION_FILE")
DURATION=$(yq eval '.duration_days' "$EXCEPTION_FILE")
REQUESTOR=$(yq eval '.requested_by' "$EXCEPTION_FILE")
APPROVER=$(yq eval '.approver' "$EXCEPTION_FILE")

echo "Exception Details:"
echo "  Service: $SERVICE"
echo "  Environment: $ENVIRONMENT"
echo "  Scope: $SCOPE"
echo "  Duration: $DURATION days"
echo "  Requested by: $REQUESTOR"
echo "  Approver: $APPROVER"
echo ""

# Validation 1: Check self-approval
echo "1. Checking for self-approval..."
if [ "$REQUESTOR" == "$APPROVER" ]; then
    echo "❌ VALIDATION FAILED: Self-approval not allowed"
    echo "   Requestor and approver must be different people"
    exit 1
fi
echo "✅ Not a self-approval"
echo ""

# Validation 2: Check scope vs duration
echo "2. Validating scope vs duration..."

case "$SCOPE" in
    "service-env")
        MAX_DURATION=30
        if [ "$DURATION" -gt "$MAX_DURATION" ]; then
            echo "❌ VALIDATION FAILED: Duration exceeds maximum for service-env scope"
            echo "   Maximum: $MAX_DURATION days, Requested: $DURATION days"
            exit 1
        fi
        echo "✅ Duration within limits for service-env scope"
        ;;
    
    "service")
        MAX_DURATION=14
        if [ "$DURATION" -gt "$MAX_DURATION" ]; then
            echo "❌ VALIDATION FAILED: Duration exceeds maximum for service scope"
            echo "   Maximum: $MAX_DURATION days, Requested: $DURATION days"
            exit 1
        fi
        if [ "$ENVIRONMENT" == "*" ]; then
            echo "⚠️  WARNING: Exception applies to all environments"
            echo "   Consider narrowing to specific environment"
        fi
        ;;
    
    "team")
        MAX_DURATION=14
        if [ "$DURATION" -gt "$MAX_DURATION" ]; then
            echo "❌ VALIDATION FAILED: Duration exceeds maximum for team scope"
            echo "   Maximum: $MAX_DURATION days, Requested: $DURATION days"
            exit 1
        fi
        echo "⚠️  WARNING: Broad team-level exception"
        echo "   Consider separate per-service exceptions"
        ;;
    
    "cross-team")
        MAX_DURATION=7
        if [ "$DURATION" -gt "$MAX_DURATION" ]; then
            echo "❌ VALIDATION FAILED: Duration exceeds maximum for cross-team scope"
            echo "   Maximum: $MAX_DURATION days, Requested: $DURATION days"
            exit 1
        fi
        echo "⚠️  WARNING: Cross-team exception requires VP approval"
        ;;
    
    "global")
        MAX_DURATION=7
        if [ "$DURATION" -gt "$MAX_DURATION" ]; then
            echo "❌ VALIDATION FAILED: Production-wide exceptions limited to 7 days"
            echo "   Maximum: $MAX_DURATION days, Requested: $DURATION days"
            exit 1
        fi
        echo "⚠️  ALERT: Production-wide exception (highest risk)"
        echo "   Requires VP Engineering approval"
        echo "   Requires incident context"
        ;;
    
    *)
        echo "❌ VALIDATION FAILED: Unknown scope: $SCOPE"
        exit 1
        ;;
esac
echo ""

# Validation 3: Check approver authority for scope
echo "3. Validating approver authority..."

REQUIRED_APPROVER=""
case "$SCOPE" in
    "service-env"|"service")
        REQUIRED_APPROVER="platform-lead"
        ;;
    "team")
        REQUIRED_APPROVER="engineering-manager"
        ;;
    "cross-team"|"global")
        REQUIRED_APPROVER="vp-engineering"
        ;;
esac

# Check if approver has required role (simplified check)
if ! echo "$APPROVER" | grep -q "$REQUIRED_APPROVER"; then
    echo "⚠️  WARNING: Approver role may not match exception scope"
    echo "   Scope: $SCOPE requires approver: $REQUIRED_APPROVER"
    echo "   Provided approver: $APPROVER"
fi
echo ""

# Validation 4: Suggest narrower scope if possible
echo "4. Checking for optimization opportunities..."

if [ "$SCOPE" == "service" ] && [ "$ENVIRONMENT" != "*" ]; then
    echo "💡 SUGGESTION: Narrow scope to service-env"
    echo "   Current: service (all environments)"
    echo "   Suggested: service-env (specific environment)"
    echo "   Benefits: Reduces blast radius, allows longer duration"
fi

if [ "$SCOPE" == "team" ]; then
    echo "💡 SUGGESTION: Consider separate per-service exceptions"
    echo "   Current: Team-wide exception"
    echo "   Alternative: Individual service exceptions"
    echo "   Benefits: Clearer ownership, independent expiration"
fi

if [ "$SCOPE" == "global" ]; then
    echo "⚠️  CRITICAL: Production-wide exception"
    echo "   This affects ALL services in production"
    echo "   Is there a narrower scope that would work?"
    echo "   Even team-level scope would significantly reduce risk"
fi

echo ""
echo "================================================"
echo "Validation complete"
echo ""

if [ "$SCOPE" == "global" ] || [ "$SCOPE" == "cross-team" ]; then
    echo "⚠️  High-risk exception requiring executive approval"
    exit 2  # Warning exit code
else
    echo "✅ Exception scope validated"
    exit 0
fi