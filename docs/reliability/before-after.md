# Before and After: AI-Generated vs Production-Ready

## The Original AI-Generated Manifest

```yaml
spec:
  replicas: 1  # ❌ Single replica
  template:
    spec:
      containers:
      - name: aggregator
        image: teriana/data-aggregator:v1.0.0
        # ❌ No resource limits
        # ❌ No health probes
        # ❌ No security context
```

## What Was Missing

### 1. Resource Limits (BLOCKING)
**Original:** No `resources.limits`
**Risk:** Pod can consume all node memory
**Incident:** Traffic spike caused memory exhaustion, crashed neighboring pods

**Fixed:**
```yaml
resources:
  limits:
    memory: "512Mi"
    cpu: "500m"
  requests:
    memory: "256Mi"
    cpu: "250m"
```

### 2. Liveness Probe (WARNING)
**Original:** No `livenessProbe`
**Risk:** Kubernetes can't detect unresponsive containers
**Incident:** Database timeout left service deadlocked, required manual restart

**Fixed:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
```

### 3. Readiness Probe (WARNING)
**Original:** No `readinessProbe`
**Risk:** Traffic routes to pods that aren't ready
**Incident:** Database timeout kept service in rotation, 100% error rate for 15 minutes

**Fixed:**
```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 2
```

### 4. Security Context (WARNING/BLOCKING)
**Original:** No `securityContext`
**Risk:** Container runs as root by default
**Impact:** Violates security best practices, potential privilege escalation

**Fixed:**
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

### 5. Single Replica (WARNING)
**Original:** `replicas: 1`
**Risk:** No redundancy during updates or failures
**Incident:** Node drain for security patch caused 30-minute outage

**Fixed:**
```yaml
spec:
  replicas: 3
```

### 6. No Anti-Affinity (WARNING)
**Original:** No `affinity` rules
**Risk:** All replicas could land on same node
**Impact:** Node failure would take down all replicas

**Fixed:**
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - data-aggregator
        topologyKey: kubernetes.io/hostname
```

### 7. No PodDisruptionBudget (RECOMMENDED)
**Original:** No PDB
**Risk:** Maintenance could disrupt all replicas simultaneously
**Impact:** Cluster upgrades could cause service outage

**Fixed:**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: data-aggregator-pdb
spec:
  minAvailable: 2
```

## Policy Enforcement Results

### Original Manifest
```bash
$ ./scripts/validation/validate-reliability.sh deployments/data-aggregator.yaml

❌ BLOCKING VIOLATIONS:
- Container 'aggregator' missing memory limit
- Container 'aggregator' missing CPU limit

⚠️  WARNINGS:
- Container 'aggregator' missing liveness probe
- Container 'aggregator' missing readiness probe  
- Container 'aggregator' missing security context
- Deployment has only 1 replica in production

Blocking violations: 2
Warnings: 4
```

### Fixed Manifest
```bash
$ ./scripts/validation/validate-reliability.sh deployments/data-aggregator-fixed.yaml

✅ All reliability checks passed!

Blocking violations: 0
Warnings: 0
```

## Incident Prevention

| Incident | Root Cause | Would Have Been Prevented By |
|----------|-----------|------------------------------|
| Memory exhaustion crash | No resource limits | Resource limit policy (BLOCK) |
| Database timeout unresponsive | No liveness probe | Liveness probe policy (WARN) |
| Serving errors while broken | No readiness probe | Readiness probe policy (WARN) |
| Outage during node maintenance | Single replica | Replica count policy (WARN) + PDB |

All three production incidents would have been prevented by the policy framework.