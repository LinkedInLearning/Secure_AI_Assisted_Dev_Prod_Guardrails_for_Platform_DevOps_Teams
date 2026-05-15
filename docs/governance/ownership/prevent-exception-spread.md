# Preventing Exception Contagion

## The Problem

One exception can spread:

**Scenario:**
1. Service A gets GPL exception for customer integration
2. Service B sees this and requests GPL exception
3. Service C does the same
4. Six months later: 12 services with GPL exceptions
5. Standards have eroded

## Prevention Strategies

### 1. Narrow Scope Requirements

Force exceptions to be as narrow as possible:
- Single service, not team-wide
- Single environment, not all environments
- Specific justification, not "same as Service A"

### 2. No Precedent-Based Requests

❌ "Service A has this exception, we should too"
✅ "We need this exception because [specific business reason]"

Each exception judged on its own merits.

### 3. Track Exception Patterns

Monitor for:
- Same guardrail exception across multiple services
- Same justification used repeatedly
- One team accumulating many exceptions

When pattern detected = systemic issue needing platform-level solution.

### 4. Exception Debt Review

Weekly review flags:
- Multiple services with same exception type
- Team with >3 active exceptions
- Exception that's been renewed >2 times

Platform team investigates and addresses root cause.

### 5. Platform Solutions Over Individual Exceptions

When 3+ services need same exception:
- Build platform capability that eliminates the need
- Update guardrail to handle legitimate use case
- Create approved pattern that services can follow

Example: If 3 services need GPL exceptions for same customer API:
- Platform team builds shared integration service
- GPL code isolated in platform-managed component
- Individual services don't need exceptions

## Example: Exception Spreading Prevented

**Initial Request:**
Service A needs GPL library for FarmCo integration.

**Narrow Approval:**
- Scope: sensor-integration-service only
- Environment: production only
- Duration: 14 days
- Remediation: Migrate to MIT alternative

**Subsequent Request:**
Service B requests GPL library for FarmCo integration.

**Platform Response:**
"We're seeing a pattern. Two services need FarmCo integration. Rather than grant another exception, we're building a shared FarmCo integration service. Service A and B will use this platform service. ETA: 10 days."

**Result:**
- No exception spread
- Platform solution created
- Two services served
- Future services can use the platform component
- No more FarmCo GPL exceptions needed