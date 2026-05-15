-- Exception Tracking Database Schema

CREATE TABLE exceptions (
    id SERIAL PRIMARY KEY,
    exception_id VARCHAR(50) UNIQUE NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    guardrail_type VARCHAR(50) NOT NULL,
    justification TEXT NOT NULL,
    risk_assessment TEXT NOT NULL,
    
    -- Approval tracking
    status VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending, approved, denied, expired
    requested_by VARCHAR(100) NOT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT NOW(),
    approved_by VARCHAR(100),
    approved_at TIMESTAMP,
    
    -- Duration tracking
    duration_days INTEGER NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    expired BOOLEAN DEFAULT FALSE,
    
    -- Remediation tracking
    remediation_plan TEXT NOT NULL,
    remediation_target_date DATE NOT NULL,
    remediation_ticket_id VARCHAR(50),
    remediation_completed BOOLEAN DEFAULT FALSE,
    remediation_completed_at TIMESTAMP,
    
    -- Audit trail
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMP,
    
    CONSTRAINT valid_status CHECK (status IN ('pending', 'approved', 'denied', 'expired', 'closed'))
);

CREATE INDEX idx_exceptions_status ON exceptions(status);
CREATE INDEX idx_exceptions_service ON exceptions(service_name);
CREATE INDEX idx_exceptions_expires ON exceptions(expires_at);
CREATE INDEX idx_exceptions_type ON exceptions(guardrail_type);

CREATE TABLE exception_audit_log (
    id SERIAL PRIMARY KEY,
    exception_id VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,  -- created, approved, denied, expired, extended, closed
    actor VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    details JSONB,
    
    FOREIGN KEY (exception_id) REFERENCES exceptions(exception_id)
);

CREATE INDEX idx_audit_exception ON exception_audit_log(exception_id);
CREATE INDEX idx_audit_timestamp ON exception_audit_log(timestamp);

-- View for active exceptions
CREATE VIEW active_exceptions AS
SELECT 
    exception_id,
    service_name,
    guardrail_type,
    requested_by,
    approved_by,
    duration_days,
    expires_at,
    EXTRACT(DAY FROM (expires_at - NOW())) AS days_remaining,
    remediation_target_date,
    remediation_completed
FROM exceptions
WHERE status = 'approved' 
  AND NOT expired
  AND expires_at > NOW();

-- View for exception debt
CREATE VIEW exception_debt AS
SELECT 
    service_name,
    COUNT(*) AS active_exception_count,
    AVG(duration_days) AS avg_duration_days,
    COUNT(*) FILTER (WHERE remediation_target_date < CURRENT_DATE) AS overdue_count
FROM exceptions
WHERE status = 'approved' 
  AND NOT expired
GROUP BY service_name
HAVING COUNT(*) > 0;