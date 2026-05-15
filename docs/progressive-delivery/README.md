# Progressive Delivery

Progressive delivery limits blast radius by rolling out changes gradually with automated health checks.

## How It Works

### 1. Canary Deployment
New version deployed alongside current version. Traffic gradually shifts from stable to canary.

### 2. Progressive Traffic Shifting
```
Stable: 100% → 95% → 75% → 50% → 25% → 0%
Canary: 0%   → 5%  → 25% → 50% → 75% → 100%
```

### 3. Automated Health Checks
At each traffic percentage, metrics are monitored:
- Error rate
- Latency (P95, P99)
- Success rate
- Resource usage

### 4. Automatic Progression or Rollback
- **All checks pass:** Progress to next traffic percentage
- **Any check fails 3 consecutive times:** Automatic rollback

## Why This Matters

**Traditional deployment:**
- 100% of traffic on new version immediately
- If bad deployment, 100% of users affected
- Manual detection and rollback takes 15-30 minutes

**Progressive delivery:**
- 5-50% of traffic on new version initially
- If bad deployment, limited blast radius
- Automatic detection and rollback in <1 minute

## Real Example: Connection Leak

v2.4.0 had a database connection leak. Traditional deployment would have:
- Deployed to all 10 pods immediately
- Exhausted connection pool within 2 minutes
- Caused 100% outage
- Required 30 minutes to detect, diagnose, and rollback

Progressive delivery:
- Deployed to 1 canary pod (5% traffic)
- Leak detected after 3 minutes at 25% traffic
- Automatic rollback triggered
- Only 25% of users affected for 5 minutes
- No manual intervention needed

## Configuration

See `config/rollout-policies/` for:
- Traffic progression schedules
- Health check thresholds
- Rollback policies
- Analysis templates