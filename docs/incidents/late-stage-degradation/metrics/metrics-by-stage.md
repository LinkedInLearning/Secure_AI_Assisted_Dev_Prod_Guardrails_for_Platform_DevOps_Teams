# Metrics by Rollout Stage

## Complete Metrics Timeline

| Time   | Traffic | Error % | P50   | P95   | P99    | Memory | Connections | Throughput |
|--------|---------|---------|-------|-------|--------|--------|-------------|------------|
| T+1    | 5%      | 0.3%    | 85ms  | 220ms | 450ms  | 35%    | 15/100      | 50 req/s   |
| T+6    | 25%     | 0.5%    | 90ms  | 240ms | 520ms  | 42%    | 38/100      | 250 req/s  |
| T+11   | 50%     | 0.8%    | 95ms  | 280ms | 680ms  | 58%    | 62/100      | 495 req/s  |
| T+16   | 75%     | 1.2%    | 105ms | 320ms | 950ms  | 71%    | 84/100      | 735 req/s  |
| T+21   | 75%     | 2.8%    | 125ms | 450ms | 1800ms | 82%    | 94/100      | 680 req/s  |
| T+26   | 75%     | 6.5%    | 180ms | 850ms | 3200ms | 89%    | 98/100      | 580 req/s  |
| T+31   | 75%     | 15.2%   | 450ms | 2800ms| 8500ms | 95%    | 100/100     | 420 req/s  |

## Signal Analysis

### Error Rate Progression
```
T+1  (5%):  0.3%  ✅
T+6  (25%): 0.5%  ✅
T+11 (50%): 0.8%  ✅
T+16 (75%): 1.2%  ✅ (below 5% threshold)
T+21 (75%): 2.8%  ⚠️ (approaching threshold)
T+26 (75%): 6.5%  ❌ (exceeds 5% threshold) ← Should have triggered rollback
T+31 (75%): 15.2% ❌ (critical)
```

**Problem:** Error rate monitoring was disabled after 50% traffic in current config

### P99 Latency Progression
```
T+1  (5%):  450ms
T+6  (25%): 520ms  (1.16x increase)
T+11 (50%): 680ms  (1.31x increase)
T+16 (75%): 950ms  (1.40x increase)
T+21 (75%): 1800ms (1.89x increase) ← 2x regression, should trigger
T+26 (75%): 3200ms (1.78x increase)
T+31 (75%): 8500ms (2.66x increase)
```

**Problem:** Only monitoring P95 (500ms threshold), not P99 (2000ms threshold)
**Problem:** No monitoring of latency growth rate

### Connection Pool Usage
```
T+1  (5%):  15/100 (15%)
T+6  (25%): 38/100 (38%)
T+11 (50%): 62/100 (62%)
T+16 (75%): 84/100 (84%) ← Should trigger warning
T+21 (75%): 94/100 (94%) ← Should trigger rollback
T+26 (75%): 98/100 (98%) ← Critical
T+31 (75%): 100/100 (100%) ← Exhausted
```

**Problem:** Connection pool usage not monitored at all

### Throughput Drop
```
T+16 (75%): 735 req/s (expected: 750) = 98% ✅
T+21 (75%): 680 req/s (expected: 750) = 91% ✅ (above 70% threshold)
T+26 (75%): 580 req/s (expected: 750) = 77% ✅ (still above 70% threshold)
T+31 (75%): 420 req/s (expected: 750) = 56% ❌ (below 70% threshold)
```

**Problem:** 30% drop threshold too permissive
**Problem:** Should have triggered at T+21 with 20% drop threshold

### Memory Growth Rate

```
T+11 (50%): 58%
T+16 (75%): 71%  (+13% in 5 min) ⚠️
T+21 (75%): 82%  (+11% in 5 min) ⚠️
T+26 (75%): 89%  (+7% in 5 min)  ⚠️
T+31 (75%): 95%  (+6% in 5 min)  ❌
```

**Problem:** Memory growth rate not monitored
**Problem:** No threshold for rapid resource consumption