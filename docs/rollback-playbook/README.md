# Rollback Playbook: Standardize Reversible Delivery

## Overview

The rollback playbook defines comprehensive guardrails that detect failures early and trigger automatic rollback before critical impact.

## Guardrail Categories

### 1. Error Rate Monitoring
**What:** Percentage of failed requests
**Why:** Direct measurement of user-facing failures
**Threshold:** 5% maximum, tightens to 2% at 75% traffic
**Catches:** Application errors, unhandled exceptions, integration failures

### 2. Latency Monitoring (P50, P95, P99)
**What:** Request duration at different percentiles
**Why:** P99 catches tail latency that affects subset of users
**Thresholds:** P50 <200ms, P95 <500ms, P99 <2000ms
**Catches:** Performance regressions, resource contention, slow queries

### 3. Latency Growth Rate
**What:** How fast latency increases over time
**Why:** Catches progressive degradation (memory leaks, connection leaks)
**Threshold:** 2x increase in 10 minutes
**Catches:** Memory leaks, connection pool exhaustion, cache pollution

### 4. Throughput Monitoring
**What:** Request rate the service can process
**Why:** Capacity problems appear as throughput drop
**Threshold:** 20% drop from expected
**Catches:** Thread exhaustion, CPU saturation, blocking operations

### 5. Connection Pool Usage
**What:** Percentage of database connections in use
**Why:** Leading indicator of resource exhaustion
**Threshold:** 80% triggers rollback
**Catches:** Connection leaks, connection pool misconfiguration

### 6. Memory Usage and Growth
**What:** Memory consumption and rate of increase
**Why:** Memory leaks show up as sustained growth
**Thresholds:** 90% absolute, 15% growth in 5 minutes
**Catches:** Memory leaks, unbounded caches, object retention

### 7. Health Check Failures
**What:** Liveness and readiness probe failures
**Why:** Service can't respond to basic health checks
**Threshold:** 2 liveness failures, 5 readiness failures
**Catches:** Deadlocks, thread exhaustion, unresponsive processes

### 8. Progressive Degradation Detection
**What:** Multiple metrics degrading simultaneously
**Why:** Real problems affect multiple dimensions
**Threshold:** 3+ metrics degrading at once
**Catches:** Systemic issues vs transient spikes

## How Guardrails Work Together

### Early Warning (T+0 to T+15)
- P99 latency trending up
- Connection pool climbing
- Memory growing steadily

### Approaching Threshold (T+15 to T+20)
- Multiple metrics show degradation
- Connection pool at 70-80%
- Latency growth rate accelerating

### Automatic Rollback (T+20 to T+25)
- Connection pool exceeds 80%
- Multiple consecutive breaches
- Progressive degradation confirmed
- **Rollback triggered automatically**

### Post-Rollback
- Metrics recover immediately
- Canary pods kept for debugging
- Incident created automatically
- 10-minute cooldown before retry

## Traffic-Dependent Thresholds

Thresholds tighten as traffic increases:

| Traffic % | Error Rate | Why |
|-----------|------------|-----|
| 5%        | 10%        | Small sample, allow variance |
| 25%       | 5%         | Moderate confidence |
| 50%       | 3%         | High confidence |
| 75%       | 2%         | Very high confidence |

Higher traffic = more confidence = stricter thresholds

## Rate-of-Change vs Absolute Thresholds

### Absolute Thresholds
- **Good for:** Acute failures
- **Example:** Error rate >5%, P99 >2000ms
- **Catches:** Crashes, bad deployments, broken features

### Rate-of-Change Thresholds
- **Good for:** Progressive failures
- **Example:** Memory +15% in 5min, Latency 2x in 10min
- **Catches:** Leaks, saturation, degradation over time

**Use both.** Different failure modes need different detection.

## Configuration

See `config/rollback-playbook/complete-guardrails.yaml` for full configuration.

Key points:
- All thresholds tunable per environment
- Consecutive failure limits prevent false positives
- Multiple signals provide confidence
- Fast rollback execution (30 seconds)
- Automatic incident creation and notification