#!/bin/bash
# Collects guardrail effectiveness metrics from various sources

set -e

DB_HOST="${DB_HOST:-localhost}"
DB_NAME="${DB_NAME:-platform}"
DB_USER="${DB_USER:-postgres}"

echo "Collecting Guardrail Effectiveness Metrics"
echo "=========================================="
echo ""

# Safety Metrics
echo "1. Safety Metrics (True/False Positives)"
echo "-----------------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT * FROM safety_effectiveness
  ORDER BY true_positives DESC
"
echo ""

# Friction Metrics
echo "2. Friction Metrics (Developer Experience)"
echo "------------------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT * FROM friction_by_guardrail
  ORDER BY avg_time_blocked_minutes DESC
"
echo ""

# Escape Rate Metrics
echo "3. Escape Rate Metrics (Bypasses)"
echo "---------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT * FROM escape_rate
  ORDER BY total_escapes DESC
"
echo ""

# Combined Dashboard
echo "4. Overall Effectiveness Dashboard"
echo "----------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    guardrail_type,
    true_positives,
    false_positives,
    precision_percentage || '%' as precision,
    ROUND(avg_time_blocked_minutes) || ' min' as avg_blocked_time,
    ROUND(avg_satisfaction, 1) || '/5' as satisfaction,
    total_escapes,
    health_score || '/100' as health
  FROM guardrail_effectiveness_dashboard
  ORDER BY health_score DESC
"
echo ""

# Identify problem areas
echo "5. Problem Areas (Requiring Attention)"
echo "--------------------------------------"

# High false positive rate
HIGH_FP=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT guardrail_type
  FROM safety_effectiveness
  WHERE false_positives > true_positives
")

if [ ! -z "$HIGH_FP" ]; then
  echo "⚠️  High false positive rate:"
  echo "$HIGH_FP" | sed 's/^/   - /'
  echo ""
fi

# Low developer satisfaction
LOW_SAT=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT guardrail_type
  FROM friction_by_guardrail
  WHERE avg_satisfaction < 3.0
")

if [ ! -z "$LOW_SAT" ]; then
  echo "⚠️  Low developer satisfaction (<3/5):"
  echo "$LOW_SAT" | sed 's/^/   - /'
  echo ""
fi

# High escape rate
HIGH_ESCAPE=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT guardrail_type
  FROM escape_rate
  WHERE total_escapes > 10
")

if [ ! -z "$HIGH_ESCAPE" ]; then
  echo "⚠️  High escape rate (>10 bypasses):"
  echo "$HIGH_ESCAPE" | sed 's/^/   - /'
  echo ""
fi

echo "✅ Metrics collection complete"