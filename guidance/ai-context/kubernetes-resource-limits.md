# Kubernetes Resource Limits - AI Guidance

## Context
This guidance was generated after detecting 47 instances where AI-generated Kubernetes manifests were missing resource limits, causing production incidents.

## The Problem We Saw

AI tools frequently generate Kubernetes deployments like this:

````yaml
# ❌ Missing resource limits (blocked by guardrails 47 times)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-processor
spec:
  template:
    spec:
      containers:
      - name: app
        image: data-processor:v1.0
        ports:
        - containerPort: 8080
````

**Why this fails:** No resource limits means a single pod can consume all node resources, crashing other pods.

## Always Include Resource Limits

When generating Kubernetes deployments, ALWAYS include resource requests and limits:

````yaml
# ✅ Correct (guardrail will pass)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-processor
spec:
  template:
    spec:
      containers:
      - name: app
        image: data-processor:v1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
````

## Resource Sizing Guidelines

### Small Services (APIs, background workers)
````yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
````

### Medium Services (data processing, caching)
````yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
````

### Large Services (batch processing, ML)
````yaml
resources:
  requests:
    memory: "2Gi"
    cpu: "2000m"
  limits:
    memory: "4Gi"
    cpu: "4000m"
````

## Why This Matters

**Before guidance:** 47 failures in 30 days (avg 1.5 per day)
**After guidance:** 8 failures in 30 days (avg 0.27 per day)
**Reduction:** 83% fewer failures

## Common Mistakes to Avoid

❌ Omitting resources entirely
❌ Setting limits but not requests
❌ Setting requests equal to limits (wastes resources)
❌ Setting memory limit below 256Mi (too small for most apps)
❌ Setting CPU limit below 100m (too small for most apps)

## When You See This Error
```
Guardrail failed: Missing resource limits in deployment
```

Add the resources section shown above. Start with small service defaults and adjust based on actual usage.