# Example: Missing Health Probes → Guidance

## Failure Pattern Detected

**Pattern:** `missing_health_probes`
**Occurrences:** 52 times in 30 days
**Services affected:** 12

### Example Failures

**Failure 1:**
````yaml
# AI-generated deployment
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: api
        image: sensor-api:v1.0
        ports:
        - containerPort: 8080
        # ❌ No liveness or readiness probes
````

**Error:** "Guardrail failed: Missing health probes in production deployment"

**Failure 2:**
````yaml
# AI-generated deployment
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: worker
        image: data-worker:v2.0
        # ❌ No liveness or readiness probes
````

**Error:** "Guardrail failed: Missing health probes in production deployment"

## Pattern Analysis

**Common factors:**
- AI generated Kubernetes deployment
- Production environment
- No health check probes defined
- Repeat pattern across different services

**Root cause:** AI tools don't include health probes by default because:
- Training data contains many examples without probes
- Probes require application-specific endpoints
- AI doesn't know which endpoints exist

## Guidance Generated

Created: `guidance/ai-context/kubernetes-health-probes.md`

````markdown
# Kubernetes Health Probes - AI Guidance

## Always Include Liveness and Readiness Probes

When generating Kubernetes deployments for production, ALWAYS include health probes:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Why This Matters

Without health probes:
- Kubernetes can't detect when pods are unhealthy
- Failed pods continue receiving traffic
- Service degradation goes undetected

## Default Values to Use

- Liveness initial delay: 30 seconds
- Readiness initial delay: 5 seconds
- Period: 5-10 seconds
- Endpoint: /health for liveness, /ready for readiness
````

## Results After Guidance

**30 days before guidance:** 52 failures
**30 days after guidance:** 6 failures
**Reduction:** 88%

**Remaining failures:**
- Services without /health endpoints (need implementation)
- Non-HTTP services (need TCP/exec probes)
- Legacy services (no probe support)

## Next Steps

1. ✅ Guidance deployed to AI context
2. ⏳ Monitor for 60 days
3. ⏳ Address remaining failure cases
4. ⏳ Generate specific guidance for TCP/exec probes