#!/bin/bash
# Generate weekly exception debt report

set -e

DB_HOST="${DB_HOST:-localhost}"
DB_NAME="${DB_NAME:-governance}"
DB_USER="${DB_USER:-postgres}"

REPORT_DATE=$(date -u +"%Y-%m-%d")

echo "Generating Exception Debt Report: $REPORT_DATE"
echo "================================================"
echo ""

# Active exceptions count
ACTIVE_COUNT=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT COUNT(*) FROM active_exceptions
")

echo "Active Exceptions: $ACTIVE_COUNT"
echo ""

# Exceptions by type
echo "Exceptions by Type:"
echo "-------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    guardrail_type,
    COUNT(*) as count,
    AVG(duration_days)::int as avg_duration_days
  FROM exceptions
  WHERE status = 'approved' AND NOT expired
  GROUP BY guardrail_type
  ORDER BY count DESC
"
echo ""

# Exceptions by service
echo "Exceptions by Service:"
echo "----------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    service_name,
    COUNT(*) as exception_count,
    SUM(CASE WHEN remediation_target_date < CURRENT_DATE THEN 1 ELSE 0 END) as overdue_count
  FROM exceptions
  WHERE status = 'approved' AND NOT expired
  GROUP BY service_name
  ORDER BY exception_count DESC
  LIMIT 10
"
echo ""

# Overdue remediation plans
echo "Overdue Remediation Plans:"
echo "--------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT 
    exception_id,
    service_name,
    guardrail_type,
    remediation_target_date,
    CURRENT_DATE - remediation_target_date as days_overdue
  FROM exceptions
  WHERE status = 'approved'
    AND NOT expired
    AND remediation_target_date < CURRENT_DATE
    AND NOT remediation_completed
  ORDER BY days_overdue DESC
"
echo ""

# Services with most exception debt
echo "Services with Highest Exception Debt:"
echo "-------------------------------------"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
  SELECT * FROM exception_debt
  ORDER BY active_exception_count DESC, overdue_count DESC
  LIMIT 10
"

echo ""
echo "Report generated: $REPORT_DATE"