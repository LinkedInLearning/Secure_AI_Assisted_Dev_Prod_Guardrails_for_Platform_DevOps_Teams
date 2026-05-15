# Rollback Scenario: Error Rate Spike

## Trigger: Error Rate Exceeds Threshold

**Version:** sensor-data-api v2.5.0
**Issue:** Unhandled null pointer in request validation
**Runtime Signal:** Error rate spike

## Timeline

**T+0: Deployment starts**
- v2.5.0 deployed as canary
- Traffic: 0% canary, 100% stable

**T+1min: 5% traffic to canary**
- Initial error rate: 1.2% ✅ (threshold: <10% at 5% traffic)
- Looks acceptable at low traffic

**T+6min: 25% traffic to canary**
- Error rate increases: 4.8% ✅ (threshold: <5% at 25% traffic)
- Still within threshold

**T+8min: Error rate breach detected**
- Error rate: 5.4% ❌ (threshold: <5%)
- **Failure 1/3**
- Alert: "Error rate threshold breached"

**T+9min: Second consecutive breach**
- Error rate: 6.8% ❌
- **Failure 2/3**
- Alert: "Error rate degrading, rollback imminent"

**T+10min: Third consecutive breach**
- Error rate: 8.2% ❌
- **Failure 3/3 - ROLLBACK TRIGGERED**
- Alert: "Automatic rollback initiated"

**T+10min+15sec: Rollback execution begins**
- Traffic shift: 25% → 0% to canary (30 second duration)
- All traffic routing back to stable v2.4.0

**T+10min+45sec: Rollback complete**
- Traffic: 0% canary, 100% stable
- Error rate: 0.9% ✅ (back to normal)
- Canary pods kept running for debugging

## Runtime Signals

### Error Rate Metric
```promql
sum(rate(http_requests_total{
  app="sensor-data-api",
  status=~"5..",
  version="canary"
}[2m])) 
/ 
sum(rate(http_requests_total{
  app="sensor-data-api",
  version="canary"
}[2m]))
```

### Values During Incident
| Time | Traffic | Error Rate | Status |
|------|---------|------------|--------|
| T+6  | 25%     | 4.8%       | ✅ Pass |
| T+8  | 25%     | 5.4%       | ❌ Fail 1 |
| T+9  | 25%     | 6.8%       | ❌ Fail 2 |
| T+10 | 25%     | 8.2%       | ❌ Fail 3 → Rollback |
| T+11 | 0%      | 0.9%       | ✅ Recovered |

## Impact

**Blast Radius:** 25% of users for 4 minutes
**Total Incident Duration:** 4 minutes (from first breach to rollback complete)
**Manual Intervention:** None required
**Root Cause:** Null pointer exception in request validation code

## What Prevented Outage

**Without automated rollback:**
- Error rate would continue climbing
- Manual detection: 5-10 minutes
- Manual diagnosis: 10-15 minutes
- Manual rollback: 5 minutes
- Total: 20-30 minute incident affecting all users

**With automated rollback:**
- Error rate breach detected immediately
- Automatic rollback after 3 failures (3 minutes)
- 4 minute incident affecting 25% of users
- Zero manual intervention