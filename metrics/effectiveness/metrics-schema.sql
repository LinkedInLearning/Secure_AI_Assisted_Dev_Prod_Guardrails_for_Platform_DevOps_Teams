-- Guardrail Effectiveness Metrics Schema

-- SAFETY METRICS: How well do guardrails catch real issues?

CREATE TABLE guardrail_verdicts (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Guardrail details
    guardrail_type VARCHAR(50) NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    
    -- Verdict classification
    verdict VARCHAR(20) NOT NULL,  -- block, warn, allow
    classification VARCHAR(20),     -- true_positive, false_positive, false_negative
    
    -- Issue details
    issue_severity VARCHAR(20),    -- critical, high, medium, low
    issue_found TEXT,
    
    -- Resolution tracking
    was_legitimate_block BOOLEAN,
    developer_feedback TEXT,
    time_to_resolution_minutes INTEGER,
    
    -- False positive handling
    is_false_positive BOOLEAN DEFAULT FALSE,
    false_positive_reason TEXT,
    guardrail_tuned BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_verdicts_type ON guardrail_verdicts(guardrail_type);
CREATE INDEX idx_verdicts_classification ON guardrail_verdicts(classification);
CREATE INDEX idx_verdicts_timestamp ON guardrail_verdicts(timestamp);

-- FRICTION METRICS: How much do guardrails slow teams down?

CREATE TABLE developer_friction (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Friction event
    developer_id VARCHAR(100) NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    guardrail_type VARCHAR(50) NOT NULL,
    
    -- Friction measurement
    pr_number VARCHAR(50),
    blocked_at TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    time_blocked_minutes INTEGER,
    
    -- Developer experience
    required_changes TEXT,
    complexity_rating INTEGER,  -- 1-5 scale
    developer_satisfaction INTEGER,  -- 1-5 scale
    
    -- Resolution path
    resolution_type VARCHAR(50),  -- fixed_code, tuned_guardrail, exception_granted, abandoned
    iterations_required INTEGER DEFAULT 1
);

CREATE INDEX idx_friction_developer ON developer_friction(developer_id);
CREATE INDEX idx_friction_guardrail ON developer_friction(guardrail_type);
CREATE INDEX idx_friction_resolution ON developer_friction(resolution_type);

-- ESCAPE RATE METRICS: Are people bypassing guardrails?

CREATE TABLE guardrail_escapes (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Escape event
    escape_type VARCHAR(50) NOT NULL,  -- exception, workaround, shadow_it, disabled
    service_name VARCHAR(100) NOT NULL,
    guardrail_type VARCHAR(50) NOT NULL,
    
    -- Escape details
    developer_id VARCHAR(100),
    reason TEXT,
    
    -- Exception tracking (if applicable)
    exception_id VARCHAR(50),
    exception_duration_days INTEGER,
    exception_status VARCHAR(20),  -- active, expired, permanent
    
    -- Impact
    security_risk_introduced BOOLEAN DEFAULT FALSE,
    compliance_risk_introduced BOOLEAN DEFAULT FALSE,
    
    -- Detection
    detected_how VARCHAR(50),  -- audit, incident, self_reported
    detected_at TIMESTAMP
);

CREATE INDEX idx_escapes_type ON guardrail_escapes(escape_type);
CREATE INDEX idx_escapes_guardrail ON guardrail_escapes(guardrail_type);
CREATE INDEX idx_escapes_status ON guardrail_escapes(exception_status);

-- AGGREGATE VIEWS

-- Safety effectiveness by guardrail
CREATE VIEW safety_effectiveness AS
SELECT 
    guardrail_type,
    COUNT(*) FILTER (WHERE classification = 'true_positive') as true_positives,
    COUNT(*) FILTER (WHERE classification = 'false_positive') as false_positives,
    COUNT(*) FILTER (WHERE classification = 'false_negative') as false_negatives,
    ROUND(100.0 * COUNT(*) FILTER (WHERE classification = 'true_positive') / 
          NULLIF(COUNT(*), 0), 2) as precision_percentage
FROM guardrail_verdicts
WHERE timestamp >= NOW() - INTERVAL '30 days'
GROUP BY guardrail_type;

-- Friction by guardrail
CREATE VIEW friction_by_guardrail AS
SELECT 
    guardrail_type,
    COUNT(*) as friction_events,
    AVG(time_blocked_minutes) as avg_time_blocked_minutes,
    AVG(developer_satisfaction) as avg_satisfaction,
    AVG(iterations_required) as avg_iterations,
    COUNT(*) FILTER (WHERE resolution_type = 'abandoned') as abandonment_count
FROM developer_friction
WHERE timestamp >= NOW() - INTERVAL '30 days'
GROUP BY guardrail_type;

-- Escape rate by guardrail
CREATE VIEW escape_rate AS
SELECT 
    guardrail_type,
    COUNT(*) as total_escapes,
    COUNT(*) FILTER (WHERE escape_type = 'exception') as exceptions,
    COUNT(*) FILTER (WHERE escape_type = 'workaround') as workarounds,
    COUNT(*) FILTER (WHERE escape_type = 'shadow_it') as shadow_it,
    COUNT(*) FILTER (WHERE exception_status = 'permanent') as permanent_escapes,
    AVG(exception_duration_days) as avg_exception_duration
FROM guardrail_escapes
WHERE timestamp >= NOW() - INTERVAL '30 days'
GROUP BY guardrail_type;

-- Combined effectiveness dashboard
CREATE VIEW guardrail_effectiveness_dashboard AS
SELECT 
    s.guardrail_type,
    s.true_positives,
    s.false_positives,
    s.precision_percentage,
    f.avg_time_blocked_minutes,
    f.avg_satisfaction,
    e.total_escapes,
    e.permanent_escapes,
    -- Overall health score (0-100)
    ROUND(
        (s.precision_percentage * 0.4) +  -- 40% weight on safety
        ((5 - COALESCE(f.avg_satisfaction, 3)) * 20 * 0.3) +  -- 30% weight on friction
        (GREATEST(0, 100 - (e.total_escapes * 10)) * 0.3)  -- 30% weight on escape rate
    , 2) as health_score
FROM safety_effectiveness s
LEFT JOIN friction_by_guardrail f ON s.guardrail_type = f.guardrail_type
LEFT JOIN escape_rate e ON s.guardrail_type = e.guardrail_type;