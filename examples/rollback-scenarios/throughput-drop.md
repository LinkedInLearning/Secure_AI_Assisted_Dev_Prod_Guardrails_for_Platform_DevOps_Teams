# Rollback Scenario: Throughput Anomaly

## Trigger: Request Throughput Drops 40%

**Version:** sensor-data-api v2.7.0
**Issue:** Thread pool exhaustion causing request queuing
**Runtime Signal:** Throughput drop

## Timeline

**T+0: Deployment starts**

**T+1min: 5% traffic to canary**
- Canary throughput: 48 req/s (5% of 1000 req/s)
- Stable throughput: 950 req/s
- Normal distribution

**T+6min: 25% traffic to canary**
- Expected canary throughput: 250 req/s
- Actual canary throughput: 180 req/s
- Throughput ratio: 0.72 (180/250) ✅ (threshold: >0.70)
- Slight degradation but within tolerance

**T+11min: 50% traffic to canary**
- Expected: 500 req/s
- Actual: 280 req/s
- Throughput ratio: 0.56 ❌ **Failure 1/2**
- Thread pool saturated, requests queuing

**T+13min: Throughput collapse**
- Expected: 500 req/s
- Actual: 220 req/s
- Throughput ratio: 0.44 ❌ **Failure 2/2 - ROLLBACK TRIGGERED**

**T+13min+30sec: Rollback complete**
- Throughput restored to 1000 req/s

## Runtime Signal

### Throughput Drop Query
```promql
sum(rate(http_requests_total{
  version="canary"
}[5m]))
/
sum(rate(http_requests_total{
  version="stable"
}[5m]))
```

This compares canary throughput to stable throughput.
At 50% traffic split, ratio should be ~1.0.
Ratio <0.70 indicates canary can't handle the load.

## Why This Signal Matters

**Error rate was fine:** Requests weren't failing, just slow
**Latency was elevated but not critical:** P95 was 800ms (below 2s threshold)
**But throughput drop indicated capacity problem:** Canary couldn't process requests fast enough

Without throughput monitoring:
- Canary would progress to 100%
- Thread pool would exhaust completely
- Service would effectively stop processing requests
- Would look like outage despite low error rate

With throughput monitoring:
- Anomaly detected at 50% traffic
- Rollback before capacity exhausted
- Limited blast radius