# Analysis Questions

## 1. Early Warning Signals

Review the metrics at T+11 (50% traffic):
- P99 latency was 680ms (up from 450ms at 5%)
- Connection pool was at 62/100 (62%)
- Memory was at 58%

**Questions:**
- Were these signals concerning?
- Should rollback have triggered at 50%?
- What thresholds would have caught this early?

## 2. Progressive Degradation Pattern

From T+16 to T+26 (10 minutes at 75% traffic):
- Error rate: 1.2% → 6.5% (5.4x increase)
- P99 latency: 950ms → 3200ms (3.4x increase)
- Throughput: 735 → 580 req/s (21% drop)
- Memory: 71% → 89% (18% increase)
- Connections: 84/100 → 98/100 (17% increase)

**Questions:**
- Which signal showed the clearest degradation?
- At what point should rollback have triggered?
- What rate-of-change thresholds would catch this?

## 3. Missing Guardrails

Current configuration:
- Error rate monitoring disabled after 50% traffic
- Only P95 latency monitored, not P99
- Throughput drop threshold 30% (too permissive)
- No connection pool monitoring
- No memory growth rate monitoring
- No resource exhaustion detection

**Questions:**
- Which missing guardrail would have caught this earliest?
- What threshold would you set for connection pool usage?
- Should memory growth rate trigger rollback?
- How do you detect progressive vs sudden failures?

## 4. Blast Radius

Actual impact:
- 30 minutes from first degradation to rollback
- 15 minutes of critical failure (error rate >5%)
- 75% of users affected

If rollback had triggered at T+21 (94% connection pool usage):
- 10 minutes from first degradation to rollback
- 0 minutes of critical failure
- Blast radius limited to early degradation phase

**Questions:**
- How much impact was preventable?
- What's the right balance between false positives and late detection?
- Should thresholds tighten at higher traffic percentages?