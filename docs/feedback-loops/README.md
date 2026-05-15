# Feedback Loops: Turning Failures into Guidance

## Overview

When AI-generated code fails guardrails, we don't just block it. We analyze the failure, detect patterns, and generate guidance that helps AI tools avoid the same mistake in future.

## The Feedback Loop
```
1. AI generates code
2. Guardrail catches issue
3. Failure logged and analyzed
4. Pattern detected (if recurring)
5. Guidance generated
6. Guidance injected into AI context
7. AI generates better code
8. Fewer guardrail failures
```

## How It Works

### Step 1: Failure Logging
Every guardrail failure is logged with:
- What failed (missing resource limits, insecure default, etc.)
- What code was generated
- Which AI tool was used
- When and where it happened

### Step 2: Pattern Detection
Daily analysis identifies patterns:
- Same failure type across multiple services
- Same mistake repeated by same team
- Failures that occur frequently (>3 times per week)

### Step 3: Guidance Generation
For recurring patterns, we create guidance documents that:
- Explain what went wrong
- Show correct examples
- Provide reasoning (why it matters)
- Include code snippets AI can learn from

### Step 4: Context Injection
Guidance is injected into AI tool context:
- Added to `.github/copilot-instructions.md`
- Included in Cursor rules
- Referenced in PR templates
- Shown in IDE hints

### Step 5: Measurement
Track effectiveness:
- Failure rate before guidance
- Failure rate after guidance
- Reduction percentage
- Time to improvement

## Real Example: Missing Resource Limits

**Pattern detected:** 47 failures in 30 days
**AI-generated code:**
````yaml
# Missing resources section
containers:
- name: app
  image: my-app:v1.0
````

**Guidance created:** Always include resource requests and limits
**Results:** 83% reduction in failures (8 failures in next 30 days)

## Current Metrics

- **Active guidance documents:** 12
- **Average failure reduction:** 78%
- **Patterns awaiting guidance:** 3
- **Most improved pattern:** Dockerfile root user (89% reduction)

## Guidance Library

All guidance is in `guidance/ai-context/`:
- kubernetes-resource-limits.md
- terraform-network-security.md
- dockerfile-user-context.md
- kubernetes-health-probes.md
- [and more]