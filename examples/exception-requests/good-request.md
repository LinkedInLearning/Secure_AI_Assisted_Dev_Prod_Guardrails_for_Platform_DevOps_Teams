# Good Exception Request Example

## Exception Request: GPL Dependency for Customer Integration

**Service:** customer-integration-service
**Guardrail:** License policy (GPL dependency blocked)
**Duration:** 14 days
**Status:** Approved

### Business Justification

FarmCo customer contract requires integration with their proprietary farm management system. The only available SDK for their API is GPL-licensed (`farmco-sdk`). This integration is worth $500K annually and contract requires delivery by June 1st.

Legal has reviewed and provided a limited-use waiver for this specific customer integration, documented in ticket LEGAL-5421.

### Risk Assessment

**Risk:** GPL license requires our code to be open-sourced
**Mitigation:** 
- SDK isolated in separate microservice (`customer-integration-service`)
- Service only used for FarmCo integration
- All GPL code contained within single module
- Legal waiver obtained (LEGAL-5421)
- Clear technical boundaries prevent GPL contamination of main codebase

**Impact if denied:** $500K contract at risk, customer deadline missed

### Remediation Plan

**Target Date:** 2026-06-15 (14 days from approval)

**Plan:**
1. Complete FarmCo integration with GPL SDK (5 days)
2. Develop MIT-licensed alternative SDK (8 days)
3. Migrate FarmCo integration to new SDK (1 day)
4. Remove GPL dependency
5. Close exception

**Ticket:** PLAT-8847

### Why This is a Good Request

✅ **Clear business justification:** $500K contract, specific customer deadline
✅ **Risk properly assessed:** Legal review completed, isolation strategy defined
✅ **Time-limited:** 14 days, specific remediation target
✅ **Concrete remediation plan:** Detailed steps, realistic timeline, ticket created
✅ **Appropriate approver:** VP Engineering + Legal (compliance exception)
✅ **Mitigation in place:** Isolated service, legal waiver, technical boundaries

### Approval

**Approved by:** @vp-engineering, @legal-counsel
**Approved on:** 2026-05-15
**Expires on:** 2026-05-29 (14 days)
**Auto-expires:** Yes
**Remediation ticket:** PLAT-8847