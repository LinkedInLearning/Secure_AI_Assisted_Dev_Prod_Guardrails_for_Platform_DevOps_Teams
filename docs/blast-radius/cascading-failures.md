# How Unsafe Defaults Amplify Blast Radius

This document explains how missing safety defaults turn isolated failures into cascading outages.

## Definition: Blast Radius

**Blast radius** is how many systems, services, or users are affected when a single component fails.

- **Small blast radius**: One container restarts, other containers unaffected
- **Large blast radius**: One container failure crashes node, affecting all pods

The goal is to contain failures. Unsafe defaults amplify failures instead of containing them.

## Scenario 1: Memory Exhaustion Cascade

### The Failure Chain
Database slow → API waits indefinitely → Threads exhausted → Can't accept requests → Load balancer retries → Other instances also exhaust threads → Total outage

**Timeline:**
- T+0: Database query latency increases to 5 seconds (normal: 50ms)
- T+30sec: api-gateway has 200 threads, all blocked waiting for database
- T+31sec: New requests can't get threads, connections rejected
- T+32sec: Load balancer sees failures, sends traffic to other instances
- T+1min: All 3 api-gateway instances thread exhausted
- T+1min: 100% of API requests failing

**Blast Radius:**
- Without circuit breaker: 1 slow dependency → all API instances down → 100% error rate
- With circuit breaker: 1 slow dependency → degraded responses → service stays up

### Why Circuit Breakers Contain Failures

Circuit breakers fail fast instead of waiting:
1. Detect failure rate (5+ failures)
2. Open circuit (stop calling dependency)
3. Return immediate error or fallback
4. Threads don't block waiting
5. Service stays responsive

CLOSED → requests pass through
↓ (5 failures detected)
OPEN → requests fail immediately
↓ (30 seconds elapsed)
HALF_OPEN → try one request
↓ (success)
CLOSED → resume normal operation

Without circuit breakers, threads block forever waiting for the dependency. All threads exhaust. Service becomes unresponsive.

## Scenario 3: Health Probe Cascade

### The Failure Chain
Pod fails → No readiness probe → Stays in service → Load balancer sends traffic → Every request fails → 100% error rate instead of partial capacity

**Timeline:**
- T+0: Database connection pool exhausted
- T+1sec: api-gateway pods can't connect to database
- T+1sec: All requests return 500 errors
- T+1sec: Pods stay in Kubernetes Service (no readiness probe)
- T+2sec: 100% of user traffic routed to broken pods
- T+2sec: 100% error rate

**Blast Radius:**
- Without readiness probe: All pods broken → 100% error rate → total outage
- With readiness probe: Failed pods removed → working pods serve traffic → degraded capacity

### Why Readiness Probes Contain Failures

Readiness probes remove unhealthy pods from service:
1. Probe checks dependency health
2. Probe fails when database unreachable
3. Kubernetes removes pod from Service endpoints
4. Load balancer stops sending traffic to this pod
5. Other healthy pods continue serving traffic

```yaml
readinessProbe:
  httpGet:
    path: /ready  # Checks database connection
    port: 80
  failureThreshold: 2  # Remove after 2 failures
```

Without probes, broken pods keep receiving traffic. Every request fails. With probes, only healthy pods serve traffic. Partial capacity maintained.

## Scenario 4: Connection Pool Cascade

### The Failure Chain
Traffic spike → Unlimited connections → Database connection limit reached → New connections rejected → More retries → Both services overloaded

**Timeline:**
- T+0: Traffic spike: 1000 requests/second (normal: 100)
- T+5sec: api-gateway opening 300 connections to database
- T+10sec: Database at connection limit (100)
- T+11sec: New connection attempts rejected
- T+11sec: api-gateway retrying failed connections
- T+12sec: Thread pool exhausted retrying connections
- T+12sec: Both api-gateway and database overloaded

**Blast Radius:**
- Without connection pool: Traffic spike → both services down → total outage
- With connection pool: Traffic spike → requests queue → degraded performance

### Why Connection Pools Contain Failures

Connection pools bound resource usage:
1. Pre-allocate fixed number of connections (10)
2. Requests queue waiting for available connection
3. Database never exceeds safe connection count
4. Timeout if queue too long
5. Database stays stable

```yaml
env:
- name: DB_POOL_SIZE
  value: "10"  # Max 10 connections
- name: DB_POOL_QUEUE_TIMEOUT_MS
  value: "5000"  # Wait max 5 seconds
```

Without pools, each request opens a new connection. Database overwhelmed. With pools, connections bounded. Database stable. Requests may queue or timeout, but service doesn't crash.

## Key Principle: Amplification vs Containment

**Unsafe defaults amplify failures:**
- 1 bug → node crash → 20 services down
- 1 slow dependency → all API instances down
- 1 broken pod → 100% error rate
- 1 traffic spike → database and API both down

**Safe defaults contain failures:**
- 1 bug → 1 container restart
- 1 slow dependency → degraded responses
- 1 broken pod → reduced capacity
- 1 traffic spike → queuing and timeouts

The difference is boundaries. Limits, timeouts, circuit breakers, health probes, and connection pools all create boundaries that prevent failures from spreading.

## Blast Radius Comparison

| Scenario | Without Safety | With Safety | Improvement |
|----------|---------------|-------------|-------------|
| Memory leak | 20 pods killed | 1 container restart | 20x containment |
| Slow database | 100% API down | Degraded responses | Service stays up |
| Database failure | 100% error rate | 67% capacity | 2x availability |
| Traffic spike | Both services down | Requests queue | Both stay up |

Safe defaults reduce blast radius by 10x to 100x.