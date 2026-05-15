-- Guardrail Failure Tracking Schema
-- Records when AI-generated code fails guardrails

CREATE TABLE guardrail_failures (
    id SERIAL PRIMARY KEY,
    failure_id VARCHAR(50) UNIQUE NOT NULL,
    
    -- When and where
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    service_name VARCHAR(100) NOT NULL,
    guardrail_type VARCHAR(50) NOT NULL,  -- policy, vulnerability, resource_limit, etc
    
    -- What failed
    failure_reason TEXT NOT NULL,
    failed_code TEXT,
    error_message TEXT,
    
    -- AI context
    ai_tool VARCHAR(50),  -- copilot, cursor, codeium, chatgpt, claude
    prompt_context TEXT,
    
    -- Pattern categorization
    failure_pattern VARCHAR(100),  -- missing_limits, insecure_default, etc
    is_repeat BOOLEAN DEFAULT FALSE,
    repeat_count INTEGER DEFAULT 1,
    
    -- Resolution
    fixed BOOLEAN DEFAULT FALSE,
    fix_applied_at TIMESTAMP,
    guidance_generated BOOLEAN DEFAULT FALSE,
    guidance_id VARCHAR(50),
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_failures_guardrail ON guardrail_failures(guardrail_type);
CREATE INDEX idx_failures_pattern ON guardrail_failures(failure_pattern);
CREATE INDEX idx_failures_service ON guardrail_failures(service_name);
CREATE INDEX idx_failures_timestamp ON guardrail_failures(timestamp);
CREATE INDEX idx_failures_repeat ON guardrail_failures(is_repeat);

CREATE TABLE failure_patterns (
    id SERIAL PRIMARY KEY,
    pattern_id VARCHAR(50) UNIQUE NOT NULL,
    pattern_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    
    -- Pattern metrics
    occurrence_count INTEGER DEFAULT 0,
    first_seen TIMESTAMP NOT NULL DEFAULT NOW(),
    last_seen TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Associated guidance
    guidance_generated BOOLEAN DEFAULT FALSE,
    guidance_id VARCHAR(50),
    guidance_effective BOOLEAN DEFAULT FALSE,
    
    -- Reduction tracking
    failures_before_guidance INTEGER DEFAULT 0,
    failures_after_guidance INTEGER DEFAULT 0,
    reduction_percentage DECIMAL(5,2),
    
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_patterns_name ON failure_patterns(pattern_name);
CREATE INDEX idx_patterns_occurrence ON failure_patterns(occurrence_count);

CREATE TABLE ai_guidance (
    id SERIAL PRIMARY KEY,
    guidance_id VARCHAR(50) UNIQUE NOT NULL,
    
    -- What guidance addresses
    failure_pattern VARCHAR(100) NOT NULL,
    guardrail_type VARCHAR(50) NOT NULL,
    
    -- Guidance content
    guidance_title VARCHAR(200) NOT NULL,
    guidance_content TEXT NOT NULL,
    code_examples TEXT,
    
    -- Effectiveness
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    failures_prevented INTEGER DEFAULT 0,
    
    -- Context where guidance applies
    applicable_services TEXT[],  -- NULL = all services
    applicable_file_patterns TEXT[],  -- e.g., ['*.yaml', 'deployment/*']
    
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_guidance_pattern ON ai_guidance(failure_pattern);
CREATE INDEX idx_guidance_active ON ai_guidance(active);

-- View for repeat failure analysis
CREATE VIEW repeat_failures AS
SELECT 
    failure_pattern,
    COUNT(*) as total_occurrences,
    SUM(repeat_count) as total_repeats,
    COUNT(*) FILTER (WHERE guidance_generated) as has_guidance,
    AVG(repeat_count) as avg_repeat_count,
    MAX(timestamp) as most_recent
FROM guardrail_failures
WHERE is_repeat = true
GROUP BY failure_pattern
HAVING COUNT(*) > 2
ORDER BY total_occurrences DESC;

-- View for guidance effectiveness
CREATE VIEW guidance_effectiveness AS
SELECT 
    g.guidance_id,
    g.guidance_title,
    g.failure_pattern,
    fp.failures_before_guidance,
    fp.failures_after_guidance,
    fp.reduction_percentage,
    g.failures_prevented
FROM ai_guidance g
JOIN failure_patterns fp ON g.failure_pattern = fp.pattern_name
WHERE g.active = true
ORDER BY fp.reduction_percentage DESC;