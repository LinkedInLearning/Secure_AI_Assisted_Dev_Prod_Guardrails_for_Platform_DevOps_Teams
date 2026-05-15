# Rollback Scenario: Latency Regression

## Trigger: P95 Latency 50% Higher Than Stable

**Version:** sensor-data-api v2.6.0
**Issue:** Inefficient database query in new feature
**Runtime Signal:** Latency regression

## Timeline

**T+0: Deployment starts**
- v2.6.0 deployed as canary

**T+1min: 5% traffic to canary**
- Canary P95: 320ms
- Stable P95: 280ms
- Regression: 1.14x ✅ (threshold: <1.5x)

**T+6min: 25% traffic to canary**
- Canary P95: 380ms
- Stable P95: 275ms
- Regression: 1.38x ✅

**T+11min: 50% traffic to canary**
- Increased load reveals inefficiency
- Canary P95: 520ms
- Stable P95: 270ms
- Regression: 1.93x ❌ **Failure 1/3**

**T+12min: Latency worsening**
- Canary P95: 680ms
- Stable P95: 265ms
- Regression: 2.57x ❌ **Failure 2/3**

**T+13min: Critical regression**
- Canary P95: 920ms
- Stable P95: 270ms
- Regression: 3.41x ❌ **Failure 3/3 - ROLLBACK TRIGGERED**

**T+13min+30sec: Rollback complete**
- Traffic: 0% canary
- P95 latency: 275ms ✅

## Runtime Signal

### Latency Regression Query
```promql
(
  histogram_quantile(0.95,
    sum(rate(http_request_duration_ms_bucket{
      version="canary"
    }[2m])) by (le)
  )
)
/
(
  histogram_quantile(0.95,
    sum(rate(http_request_duration_ms_bucket{
      version="stable"
    }[2m])) by (le)
  )
)
```

### Latency Progression
| Time | Traffic | Canary P95 | Stable P95 | Regression | Status |
|------|---------|------------|------------|------------|--------|
| T+1  | 5%      | 320ms      | 280ms      | 1.14x      | ✅ Pass |
| T+6  | 25%     | 380ms      | 275ms      | 1.38x      | ✅ Pass |
| T+11 | 50%     | 520ms      | 270ms      | 1.93x      | ❌ Fail 1 |
| T+12 | 50%     | 680ms      | 265ms      | 2.57x      | ❌ Fail 2 |
| T+13 | 50%     | 920ms      | 270ms      | 3.41x      | ❌ Fail 3 → Rollback |

## Why Regression Check Matters

**Absolute threshold alone would miss this:**
- Canary P95 of 520ms is below absolute threshold of 500ms... wait, it's above!
- But what if absolute threshold was 1000ms? Would miss the regression.

**Regression detection catches it:**
- Canary is 1.93x slower than stable
- Even if both are "acceptable," the regression indicates a problem
- Rollback prevents degradation

## Impact

**Blast Radius:** 50% of users experiencing 2-3x latency for 3 minutes
**Root Cause:** N+1 query problem in new analytics endpoint
**Prevention:** Regression threshold caught performance degradation before it became severe