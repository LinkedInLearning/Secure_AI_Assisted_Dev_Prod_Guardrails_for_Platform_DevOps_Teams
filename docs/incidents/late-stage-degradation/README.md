# Challenge: Late-Stage Degradation

## The Problem

A deployment passed early checks but degraded progressively at high traffic. Manual rollback after 30 minutes. Multiple guardrails should have triggered but didn't.

## Your Task

1. **Identify the signals** - What metrics showed degradation?
2. **Determine thresholds** - What values would have caught it?
3. **Find the gaps** - Why didn't existing guardrails trigger?
4. **Design prevention** - What guardrails would have worked?

## Files to Review

- `TIMELINE.md` - Complete incident timeline with metrics
- `metrics/metrics-by-stage.md` - Detailed metrics progression
- `ANALYSIS_QUESTIONS.md` - Questions to guide your analysis
- `config/guardrails-inadequate/current-config.yaml` - Current (broken) configuration

## Key Questions

**What signals were present?**
- Progressive error rate increase
- P99 latency degradation
- Connection pool exhaustion
- Memory growth
- Throughput decline

**Which should have triggered rollback?**
- Connection pool at 94% usage (T+21)
- Error rate exceeding 5% (T+26)
- P99 latency 2x regression (T+21)
- Throughput 20% drop (T+21)

**Why didn't they?**
- Missing thresholds
- Disabled monitoring
- Wrong metrics
- Too permissive limits

## Success Criteria

You should identify:
- All degradation signals in the timeline
- Appropriate thresholds for each signal
- When rollback should have triggered
- How much impact would have been prevented
- What guardrails need to be added