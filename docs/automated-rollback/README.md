# Automated Rollback Using Runtime Signals

Rollback happens automatically when runtime metrics breach thresholds.

## Runtime Signals

### 1. Error Rate
**Metric:** Percentage of 5xx responses
**Threshold:** 5% maximum
**Window:** 2 minutes
**Trigger:** 3 consecutive breaches

### 2. Latency Regression
**Metric:** P95 latency ratio (canary / stable)
**Threshold:** 1.5x maximum (canary can't be 50% slower)
**Window:** 2 minutes
**Trigger:** 3 consecutive breaches

### 3. Throughput Drop
**Metric:** Request rate ratio (canary / stable)
**Threshold:** 0.70 minimum (30% drop triggers rollback)
**Window:** 5 minutes
**Trigger:** 2 consecutive breaches

### 4. Success Rate
**Metric:** Percentage of 2xx/3xx responses
**Threshold:** 95% minimum
**Window:** 2 minutes
**Trigger:** 3 consecutive breaches

## Why Multiple Signals

Different issues have different signatures:

**Crash loops:** High error rate, low throughput
**Memory leaks:** Increasing latency, eventual OOM
**Thread exhaustion:** Low error rate, throughput drop
**Bad logic:** High error rate, normal latency

Using multiple signals catches all failure modes.

## Rollback Speed

**Traffic shift:** 30 seconds from decision to complete rollback
**Total time:** <1 minute from threshold breach to stable

Fast rollback limits blast radius.

## Example: Error Rate Rollback
```
T+0: Error rate 5.4% (breach 1)
T+1: Error rate 6.8% (breach 2)
T+2: Error rate 8.2% (breach 3) → ROLLBACK
T+2.5: Rollback complete
```

3 breaches = 3 minutes to detect
30 seconds to execute rollback
Total: 3.5 minutes from first signal to recovery