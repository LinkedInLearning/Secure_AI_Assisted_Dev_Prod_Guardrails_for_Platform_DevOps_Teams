#!/bin/bash
# Automatically expire exceptions that have reached their duration limit

set -e

DB_HOST="${DB_HOST:-localhost}"
DB_NAME="${DB_NAME:-governance}"
DB_USER="${DB_USER:-postgres}"

CURRENT_DATE=$(date -u +"%Y-%m-%d")
NOTIFY_THRESHOLD_DAYS=7

echo "Checking for expired exceptions: $CURRENT_DATE"
echo ""

# Find exceptions expiring today
EXPIRING_TODAY=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT exception_id, service_name, guardrail_type, requested_by, approved_by
  FROM exceptions
  WHERE status = 'approved'
    AND NOT expired
    AND DATE(expires_at) <= '$CURRENT_DATE'
")

if [ -z "$EXPIRING_TODAY" ]; then
  echo "No exceptions expiring today"
else
  echo "Expiring exceptions:"
  echo "$EXPIRING_TODAY"
  echo ""
  
  # Mark as expired
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
    UPDATE exceptions
    SET status = 'expired',
        expired = TRUE,
        closed_at = NOW()
    WHERE status = 'approved'
      AND NOT expired
      AND DATE(expires_at) <= '$CURRENT_DATE'
  "
  
  # Create audit log entries
  psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
    INSERT INTO exception_audit_log (exception_id, action, actor, details)
    SELECT 
      exception_id,
      'expired',
      'system',
      jsonb_build_object('auto_expired', true, 'expired_at', NOW())
    FROM exceptions
    WHERE status = 'expired'
      AND closed_at::date = CURRENT_DATE
  "
  
  # Send notifications
  while IFS='|' read -r exception_id service guardrail requestor approver; do
    echo "Notifying about expired exception: $exception_id"
    
    # Send Slack notification
    curl -X POST https://slack.com/api/chat.postMessage \
      -H "Authorization: Bearer $SLACK_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"channel\": \"#platform-governance\",
        \"text\": \"Exception expired: $exception_id\",
        \"blocks\": [{
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"*Exception Expired*\n\nService: $service\nGuardrail: $guardrail\nRequested by: $requestor\nApproved by: $approver\n\n:warning: The guardrail is now enforced again.\"
          }
        }]
      }"
    
    # Close GitHub issue if exists
    gh issue close "$exception_id" --comment "Exception has expired after approved duration. Guardrail is now enforced."
    
  done <<< "$EXPIRING_TODAY"
  
  echo ""
  echo "✅ Expired exceptions processed"
fi

echo ""
echo "Checking for exceptions expiring soon..."

# Find exceptions expiring within threshold
EXPIRING_SOON=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "
  SELECT exception_id, service_name, EXTRACT(DAY FROM (expires_at - NOW())) AS days_remaining
  FROM exceptions
  WHERE status = 'approved'
    AND NOT expired
    AND expires_at > NOW()
    AND expires_at <= NOW() + INTERVAL '$NOTIFY_THRESHOLD_DAYS days'
")

if [ -z "$EXPIRING_SOON" ]; then
  echo "No exceptions expiring soon"
else
  echo "Expiring soon:"
  echo "$EXPIRING_SOON"
  
  while IFS='|' read -r exception_id service days_remaining; do
    echo "Notifying about upcoming expiration: $exception_id ($days_remaining days)"
    
    curl -X POST https://slack.com/api/chat.postMessage \
      -H "Authorization: Bearer $SLACK_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"channel\": \"#platform-governance\",
        \"text\": \"Exception expiring soon: $exception_id\",
        \"blocks\": [{
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"*Exception Expiring Soon*\n\nService: $service\nException: $exception_id\nDays remaining: $days_remaining\n\n:warning: If you need an extension, file a new exception request.\"
          }
        }]
      }"
  done <<< "$EXPIRING_SOON"
fi

echo ""
echo "✅ Exception expiration check complete"