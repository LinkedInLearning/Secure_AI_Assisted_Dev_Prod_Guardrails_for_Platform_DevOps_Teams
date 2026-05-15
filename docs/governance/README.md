# Guardrail Exception Governance

## Overview

Guardrails protect production, but sometimes legitimate exceptions are needed. The exception process ensures exceptions are:
- **Justified:** Clear business reason
- **Time-limited:** Auto-expire after approved duration
- **Approved:** Appropriate stakeholder review
- **Tracked:** Audit trail and reporting
- **Remediated:** Concrete plan to fix underlying issue

## When to Request an Exception

**Valid reasons:**
- Critical customer deadline requiring temporary workaround
- Security hotfix requiring expedited deployment
- Compliance requirement needing specific configuration
- Emergency incident response

**Invalid reasons:**
- "Guardrails are annoying"
- "We want to ship faster"
- "It's probably fine"
- "We'll fix it eventually"

## Exception Request Process

### 1. File Exception Request
Use the GitHub issue template: `.github/ISSUE_TEMPLATE/exception-request.yml`

Required information:
- Service name
- Guardrail type
- Business justification
- Risk assessment
- Duration (7, 14, or 30 days)
- Remediation plan with target date
- Remediation ticket number

### 2. Approval Review
Appropriate approver reviews based on exception type:
- **Standard:** Platform Lead
- **Security:** Security Lead + CISO
- **Compliance:** VP Engineering + Legal
- **Critical:** VP Engineering

### 3. Exception Granted
If approved:
- Exception active for specified duration
- Configuration updated to allow exception
- Audit log entry created
- Expiration date set

### 4. Auto-Expiration
After approved duration:
- Exception automatically expires
- Configuration reverted to enforce guardrail
- Notifications sent to requestor and approver
- GitHub issue closed

## Exception Duration Limits

| Exception Type | Max Duration | Approver |
|---------------|--------------|----------|
| Standard | 30 days | Platform Lead |
| Security | 14 days | Security Lead |
| Compliance | 14 days | VP Eng + Legal |
| Critical | 7 days | VP Engineering |

**Absolute maximum:** 90 days (requires VP approval + extraordinary justification)

## Tracking and Reporting

### Weekly Exception Debt Report
Every Monday, platform team receives report showing:
- Active exceptions count
- Exceptions by type and service
- Overdue remediation plans
- Services with most exceptions

### Alerts
- 7 days before expiration: Warning notification
- Expiration day: Exception expires, notifications sent
- Overdue remediation: Escalation to service owner

## Best Practices

### Writing Good Exception Requests

**Do:**
- Provide specific business justification
- Assess risks honestly
- Create concrete remediation plan with timeline
- Reference tickets and documentation
- Request minimum necessary duration

**Don't:**
- Use vague justifications ("need to ship faster")
- Ignore or downplay risks
- Say "we'll fix it eventually"
- Request maximum duration by default
- View exceptions as permanent solutions

### After Exception Granted

**Your responsibilities:**
- Execute remediation plan on schedule
- Update status if issues arise
- Notify platform team when remediation complete
- Close exception early if no longer needed

### If You Need Extension

Exception extensions are rare and require:
- Clear explanation why original plan didn't work
- Updated remediation plan
- New timeline
- Re-approval

Repeated extensions indicate systemic problem that needs addressing.