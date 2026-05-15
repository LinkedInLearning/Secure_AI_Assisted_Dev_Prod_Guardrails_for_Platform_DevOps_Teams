# Dockerfile User Context - AI Guidance

## Context
This guidance was generated after detecting 28 instances where AI-generated Dockerfiles ran containers as root, violating security policies.

## The Problem We Saw

AI tools frequently generate Dockerfiles like this:

````dockerfile
# ❌ Runs as root (blocked by guardrails 28 times)
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD ["node", "server.js"]
````

**Why this fails:** Container runs as root (UID 0), giving it unnecessary privileges.

## Always Run as Non-Root User

When generating Dockerfiles, ALWAYS create and switch to a non-root user:

````dockerfile
# ✅ Correct (guardrail will pass)
FROM node:20

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Install dependencies as root (needed for npm install)
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8080
CMD ["node", "server.js"]
````

## Pattern for Different Base Images

### Node.js
````dockerfile
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
````

### Python
````dockerfile
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
````

### Go (with distroless)
````dockerfile
FROM gcr.io/distroless/static-debian11
USER nonroot:nonroot
````

## Why This Matters

**Before guidance:** 28 failures in 30 days
**After guidance:** 3 failures in 30 days
**Reduction:** 89% fewer failures

## Common Mistakes

❌ Omitting USER directive entirely
❌ Using USER root explicitly
❌ Not changing file ownership before switching user
❌ Running package manager as non-root (causes permission errors)

## When You See This Error
```
Guardrail failed: Dockerfile runs container as root
```

Add USER directive with a non-root user before the CMD/ENTRYPOINT.