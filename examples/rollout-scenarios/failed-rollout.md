# Failed Rollout: sensor-data-api v2.4.0 (Automatic Rollback)

## Timeline

**T+0: Deployment starts**
- New version v2.4.0 deployed alongside v2.3.0
- 10% of pods running new version (1 canary pod)
- Traffic: 0% to canary

**T+1min: Canary traffic starts**
- Traffic shifted: 5% to canary, 95% to stable
- Analysis begins

**T+5min: First checkpoint**
- Error rate: 1.5% ✅ (threshold: <5%)
- P95 latency: 380ms ✅ (threshold: <500ms)
- Success rate: 97.8% ✅ (threshold: >95%)
- **Decision: PASS - Progress to 25%**

**T+6min: Increase to 25%**
- Traffic shifted: 25% to canary, 75% to stable
- ~2.5 canary pods serving traffic

**T+8min: Problems detected**
- Error rate spiking: 6.2% ❌ (threshold: <5%)
- Database connection pool exhaustion detected
- New version has connection leak

**T+9min: Second failure**
- Error rate: 8.5% ❌ (threshold: <5%)
- P95 latency: 1,200ms ❌ (threshold: <500ms)
- Success rate: 91.5% ❌ (threshold: >95%)
- **Failure count: 2/3**

**T+10min: Third failure**
- Error rate: 12.3% ❌
- P95 latency: 2,800ms ❌
- Success rate: 87.7% ❌
- **Failure count: 3/3 - THRESHOLD EXCEEDED**
- **Decision: AUTOMATIC ROLLBACK TRIGGERED**

**T+10min+30sec: Rollback begins**
- Traffic immediately shifted: 0% to canary, 100% to stable
- All traffic back to v2.3.0
- Canary pods marked for termination

**T+11min: Rollback complete**
- All traffic on v2.3.0
- Error rate: 0.8% ✅ (back to normal)
- P95 latency: 260ms ✅ (back to normal)
- Canary pods terminated

**T+11min: Incident summary generated**
- Rollout failed at 25% traffic
- Maximum blast radius: 25% of users
- Incident duration: 5 minutes (from first error spike to rollback)
- Root cause: Database connection leak in v2.4.0

## Metrics During Rollout

| Time | Traffic % | Error Rate | P95 Latency | Success Rate | Decision |
|------|-----------|------------|-------------|--------------|----------|
| T+5  | 5%        | 1.5%       | 380ms       | 97.8%        | ✅ Pass   |
| T+8  | 25%       | 6.2%       | 950ms       | 93.8%        | ❌ Fail 1 |
| T+9  | 25%       | 8.5%       | 1,200ms     | 91.5%        | ❌ Fail 2 |
| T+10 | 25%       | 12.3%      | 2,800ms     | 87.7%        | ❌ Fail 3 |
| T+11 | 0% (rollback) | 0.8%   | 260ms       | 98.5%        | ✅ Recovered |

**Rollout failed: Automatic rollback after 3 consecutive failures**
**Blast radius: Limited to 25% of traffic for 5 minutes**
**Manual intervention: None required - automatic rollback worked**

## What Prevented Production Outage

Without progressive delivery:
- v2.4.0 would deploy to 100% of traffic immediately
- All users would experience 12%+ error rate
- Database connection pool would exhaust completely
- Manual detection and rollback would take 15-30 minutes
- Full production outage

With progressive delivery:
- Problem detected at 25% traffic
- Automatic rollback within 1 minute of failure threshold
- 75% of users never affected
- 5 minute incident window instead of 30+ minutes
- No manual intervention required