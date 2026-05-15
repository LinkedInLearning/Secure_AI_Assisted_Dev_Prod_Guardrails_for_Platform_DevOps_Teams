# Exception Duration Guidance

## Principle: Use the Shortest Duration That Solves the Problem

Don't default to maximum duration. Use the minimum time needed.

## Duration Selection

### 7 Days or Less
**Use for:**
- Waiting for a patch release (vendor commits specific date)
- Hotfix deployment during incident
- Production-wide or cross-team exceptions
- Any exception with broad blast radius

**Example:** "Library vendor releases patch May 20. Need 7 days to test and deploy."

### 14 Days
**Use for:**
- Testing and validation of fixes
- Service-level exceptions in production
- Migrations requiring coordination
- Feature development with known completion date

**Example:** "Complete feature development (10 days), deploy and verify (4 days)."

### 30 Days
**Use for:**
- Complex remediation requiring architecture changes
- Service-environment exceptions only (not production-wide)
- Projects with detailed breakdown of work

**Example:** "Refactor authentication module (15 days), comprehensive testing (10 days), gradual rollout (5 days)."

### Never Use Maximum by Default

❌ Bad: "I'll request 30 days to be safe"
✅ Good: "I need 14 days for X, Y, and Z"

## Scope vs Duration Matrix

| Scope | Recommended | Maximum | Reason |
|-------|-------------|---------|---------|
| service-env | 14 days | 30 days | Narrow blast radius allows longer duration |
| service (all envs) | 7 days | 14 days | Multiple environments = higher risk |
| team | 7 days | 14 days | Multiple services = higher risk |
| cross-team | 3 days | 7 days | Very broad = very short duration |
| global | 1 day | 7 days | Maximum risk = minimum duration |

## If You Need More Time

**Don't request an extension.** File a new exception request explaining:

1. Why the original plan didn't complete
2. What changed or what was underestimated
3. Updated remediation plan with new timeline
4. What will prevent this from happening again

Repeated exceptions for the same issue = systemic problem that needs root cause fix.

## Red Flags

These combinations indicate the request needs revision:

- Global scope + 30 days = Too broad for too long
- "Just in case" justification + maximum duration = No concrete plan
- Vague remediation + long duration = Unclear when it will be fixed
- Multiple extensions requested = Systemic issue not being addressed