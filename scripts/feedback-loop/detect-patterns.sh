#!/bin/bash
# Analyzes guardrail failures and detects patterns

set -e

DB_HOST="${DB_HOST:-localhost}"
DB_NAME="${DB_NAME:-platform}"
DB_USER="${DB_USER:-postgres}"

echo "Analyzing guardrail failures for patterns..."
echo "==========================================="
echo ""

# Find failures in last 30 days
THRESHOLD_DATE=$(date -d '30 days ago' +%Y-%m-%d)

echo "Analyzing failures since: $THRESHOLD_DATE"
echo ""

# Top failure patterns
echo "Top Failure Patterns:"
echo "--------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    failure_pattern,
    COUNT(*) as occurrences,
    COUNT(DISTINCT service_name) as affected_services,
    SUM(CASE WHEN is_repeat THEN 1 ELSE 0 END) as repeat_failures,
    MAX(timestamp) as most_recent
  FROM guardrail_failures
  WHERE timestamp >= '$THRESHOLD_DATE'
  GROUP BY failure_pattern
  HAVING COUNT(*) >= 3
  ORDER BY occurrences DESC
  LIMIT 10
"
echo ""

# Patterns without guidance
echo "Patterns Without Guidance (Need Attention):"
echo "-------------------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    failure_pattern,
    COUNT(*) as occurrences,
    guidance_generated
  FROM guardrail_failures
  WHERE timestamp >= '$THRESHOLD_DATE'
    AND guidance_generated = false
  GROUP BY failure_pattern, guidance_generated
  HAVING COUNT(*) >= 3
  ORDER BY occurrences DESC
"
echo ""

# Repeat failures
echo "Repeat Failures (Same Mistake Multiple Times):"
echo "-----------------------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT * FROM repeat_failures
" | head -10
echo ""

# Generate guidance recommendations
echo "Generating guidance recommendations..."
echo ""

# Find patterns that need guidance
PATTERNS_NEEDING_GUIDANCE=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT DISTINCT failure_pattern
  FROM guardrail_failures
  WHERE timestamp >= '$THRESHOLD_DATE'
    AND guidance_generated = false
  GROUP BY failure_pattern
  HAVING COUNT(*) >= 5
")

if [ -z "$PATTERNS_NEEDING_GUIDANCE" ]; then
  echo "No patterns found that need guidance generation"
else
  echo "Patterns needing guidance:"
  echo "$PATTERNS_NEEDING_GUIDANCE"
  echo ""
  
  for pattern in $PATTERNS_NEEDING_GUIDANCE; do
    echo "📝 Pattern: $pattern"
    
    # Get example failures
    EXAMPLES=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
      SELECT failure_reason
      FROM guardrail_failures
      WHERE failure_pattern = '$pattern'
      LIMIT 3
    ")
    
    echo "   Example failures:"
    echo "$EXAMPLES" | sed 's/^/     /'
    echo ""
  done
fi

echo "✅ Pattern detection complete"