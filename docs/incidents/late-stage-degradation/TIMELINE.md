# Incident: Late-Stage Degradation (Connection Pool Leak)

## Overview

**Date:** 2026-05-14
**Service:** sensor-data-api v2.8.0
**Issue:** Database connection pool leak
**Detection:** Manual (on-call engineer)
**Rollback:** Manual after 10 minutes of investigation
**Total Incident Duration:** 30 minutes from first degradation to rollback complete

## Deployment Timeline

### T+0: Deployment Starts
- Version: v2.8.0 deployed as canary
- Change: New caching layer for frequently accessed data
- Traffic: 0% canary

### T+1min: 5% Traffic to Canary
**Metrics:**
- Error rate: 0.3%
- P50 latency: 85ms
- P95 latency: 220ms
- P99 latency: 450ms
- Memory usage: 35%
- Connection pool usage: 15/100 connections
- Throughput: 50 req/s (expected: 50 req/s)

**Assessment:** ✅ All metrics healthy
**Decision:** Progress to 25%

### T+6min: 25% Traffic to Canary
**Metrics:**
- Error rate: 0.5%
- P50 latency: 90ms
- P95 latency: 240ms
- P99 latency: 520ms
- Memory usage: 42%
- Connection pool usage: 38/100 connections
- Throughput: 250 req/s (expected: 250 req/s)

**Assessment:** ✅ All metrics healthy
**Decision:** Progress to 50%

### T+11min: 50% Traffic to Canary
**Metrics:**
- Error rate: 0.8%
- P50 latency: 95ms
- P95 latency: 280ms
- P99 latency: 680ms
- Memory usage: 58%
- Connection pool usage: 62/100 connections
- Throughput: 495 req/s (expected: 500 req/s)

**Assessment:** ⚠️ Minor latency increase, P99 elevated
**Note:** P99 latency 680ms is below absolute threshold (2000ms)
**Note:** Throughput ratio 0.99 is above threshold (0.70)
**Decision:** Progress to 75%

### T+16min: 75% Traffic to Canary
**Metrics:**
- Error rate: 1.2%
- P50 latency: 105ms
- P95 latency: 320ms
- P99 latency: 950ms
- Memory usage: 71%
- Connection pool usage: 84/100 connections
- Throughput: 735 req/s (expected: 750 req/s)

**Assessment:** ⚠️ Continued degradation but within thresholds
**Note:** Error rate 1.2% is below threshold (5%)
**Note:** P95 latency 320ms is below threshold (500ms)
**Note:** P99 latency 950ms is below threshold (2000ms)
**Decision:** Monitor for 5 minutes before promoting to 100%

### T+21min: Progressive Degradation Visible
**Metrics:**
- Error rate: 2.8%
- P50 latency: 125ms
- P95 latency: 450ms
- P99 latency: 1800ms
- Memory usage: 82%
- Connection pool usage: 94/100 connections
- Throughput: 680 req/s (expected: 750 req/s)

**Assessment:** ⚠️ Degradation accelerating
**Note:** Still within absolute thresholds
**Note:** Throughput dropping but ratio still 0.91 (above 0.70 threshold)
**No automatic rollback triggered**

### T+26min: Connection Pool Near Exhaustion
**Metrics:**
- Error rate: 6.5%
- P50 latency: 180ms
- P95 latency: 850ms
- P99 latency: 3200ms
- Memory usage: 89%
- Connection pool usage: 98/100 connections
- Throughput: 580 req/s (expected: 750 req/s)

**Assessment:** ❌ Error rate exceeds threshold (5%)
**Note:** P99 latency exceeds threshold (2000ms)
**Issue:** Error rate breach should trigger rollback
**Actual:** No rollback triggered (misconfiguration: only monitoring P95, not error rate at this stage)

### T+31min: Critical Failure - Connection Pool Exhausted
**Metrics:**
- Error rate: 15.2%
- P50 latency: 450ms
- P95 latency: 2800ms
- P99 latency: 8500ms
- Memory usage: 95%
- Connection pool usage: 100/100 connections (EXHAUSTED)
- Throughput: 420 req/s (expected: 750 req/s)

**Assessment:** ❌ CRITICAL - Multiple threshold breaches
**Alert:** PagerDuty alert fired for high error rate
**Response:** On-call engineer paged

### T+36min: Investigation Begins
- Engineer reviews metrics
- Identifies connection pool exhaustion
- Sees error rate at 15%
- Notices memory climbing
- Determines rollback necessary

### T+41min: Manual Rollback Initiated
- Engineer runs manual rollback command
- Traffic shifted: 0% to canary, 100% to stable

### T+42min: Rollback Complete
**Metrics:**
- Error rate: 0.5%
- P50 latency: 88ms
- P95 latency: 235ms
- P99 latency: 480ms
- Connection pool usage: 25/100 connections

**Assessment:** ✅ Metrics recovered

## Impact Summary

**Blast Radius:**
- 75% of traffic affected
- 30 minutes from first degradation (T+11) to rollback complete (T+42)
- 15 minutes of critical failure (error rate >5%)

**User Impact:**
- ~15,000 requests affected by elevated errors
- ~45,000 requests experienced degraded latency

**Manual Intervention Required:**
- 10 minutes of engineer investigation
- Manual rollback command
- No automatic rollback despite clear degradation

## Root Cause

**Issue:** Database connection leak in new caching layer

**Mechanism:**
1. New code path opens database connection to validate cache entries
2. Connection not properly closed in error handling path
3. At low traffic (5%, 25%), connection pool recycles before exhaustion
4. At high traffic (75%), connections leak faster than they recycle
5. After 20 minutes at 75% traffic, pool exhausts
6. New requests fail immediately with "connection unavailable"

**Code Problem:**
```typescript
// Buggy code in v2.8.0
async function validateCacheEntry(key: string) {
  const conn = await db.getConnection();
  try {
    const result = await conn.query('SELECT * FROM cache WHERE key = ?', [key]);
    return result.isValid;
  } catch (error) {
    // BUG: Connection not released in error path
    throw error;
  }
  // Connection only released in success path
  conn.release();
}
```

## What Should Have Happened

**Guardrails That Should Have Triggered:**

1. **Connection Pool Usage Threshold**
   - Should trigger at 80% pool usage
   - Would have caught issue at T+21 (94/100 connections)
   - Rollback 10 minutes earlier

2. **Progressive Latency Degradation**
   - P99 increased from 450ms → 950ms → 1800ms
   - 2x regression in 10 minutes
   - Should trigger on sustained latency increase

3. **Throughput Degradation Rate**
   - Dropped from 735 req/s → 580 req/s in 5 minutes
   - 20% drop in throughput
   - Should trigger on rapid throughput decline

4. **Memory Growth Rate**
   - Increased from 71% → 89% in 10 minutes
   - 18% growth in short period
   - Should trigger on rapid resource consumption

5. **Error Rate at High Traffic**
   - Error rate exceeded 5% at T+26
   - Should have triggered immediate rollback
   - Misconfiguration: error rate monitoring disabled after 50% traffic