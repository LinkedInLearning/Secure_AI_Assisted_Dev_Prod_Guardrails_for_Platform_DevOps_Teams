-- Metrics Dashboard for Feedback Loop Effectiveness

-- Overall failure rate over time
CREATE VIEW failure_rate_trend AS
SELECT 
    DATE_TRUNC('week', timestamp) as week,
    COUNT(*) as total_failures,
    COUNT(*) FILTER (WHERE is_repeat = true) as repeat_failures,
    ROUND(100.0 * COUNT(*) FILTER (WHERE is_repeat = true) / NULLIF(COUNT(*), 0), 2) as repeat_percentage
FROM guardrail_failures
GROUP BY week
ORDER BY week DESC;

-- Failures by pattern with guidance status
CREATE VIEW pattern_guidance_status AS
SELECT 
    failure_pattern,
    COUNT(*) as total_occurrences,
    MAX(CASE WHEN guidance_generated THEN 'Yes' ELSE 'No' END) as has_guidance,
    AVG(repeat_count) as avg_repeats
FROM guardrail_failures
GROUP BY failure_pattern
ORDER BY total_occurrences DESC;

-- Most improved patterns (after guidance deployed)
CREATE VIEW most_improved_patterns AS
SELECT 
    fp.pattern_name,
    fp.failures_before_guidance,
    fp.failures_after_guidance,
    fp.reduction_percentage,
    g.guidance_title
FROM failure_patterns fp
JOIN ai_guidance g ON fp.pattern_name = g.failure_pattern
WHERE fp.guidance_generated = true
ORDER BY fp.reduction_percentage DESC;

-- Patterns still needing guidance
CREATE VIEW patterns_needing_guidance AS
SELECT 
    failure_pattern,
    COUNT(*) as occurrences,
    MAX(timestamp) as most_recent,
    COUNT(DISTINCT service_name) as affected_services
FROM guardrail_failures
WHERE guidance_generated = false
  AND timestamp >= NOW() - INTERVAL '30 days'
GROUP BY failure_pattern
HAVING COUNT(*) >= 5
ORDER BY occurrences DESC;