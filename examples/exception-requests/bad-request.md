# Bad Exception Request Example

## Exception Request: Skip Vulnerability Scan

**Service:** data-processing-service
**Guardrail:** Vulnerability threshold (High CVE blocked)
**Duration:** 90 days
**Status:** Denied

### Business Justification

The vulnerability scanner is too strict and keeps blocking our deployments. We need to ship features faster. The vulnerabilities are probably not a big deal anyway.

### Risk Assessment

I don't think there's much risk. We've been using these libraries for months in development and nothing bad happened.

### Remediation Plan

We'll look into it eventually. Maybe next quarter when we have time.

### Why This is a Bad Request

❌ **No real business justification:** "Ship faster" is not a valid reason to skip security
❌ **Risk assessment inadequate:** "Probably not a big deal" shows lack of understanding
❌ **No specific remediation:** "Eventually" and "maybe next quarter" is not a plan
❌ **Duration too long:** 90 days with no concrete plan
❌ **Missing details:** Which vulnerabilities? What CVEs? What libraries?
❌ **Wrong mindset:** Views guardrails as obstacles, not protections

### Denial Reason

**Denied by:** @security-lead
**Denied on:** 2026-05-15
**Reason:** 

"Request does not meet exception policy requirements:

1. No specific business justification provided
2. Risk assessment does not address actual security implications
3. No concrete remediation plan with timeline
4. 90-day duration is inappropriate without detailed plan
5. Attitude suggests misunderstanding of security guardrails' purpose

**Alternative approach:** Please provide:
- Specific list of vulnerabilities needing exception
- Business impact analysis for each
- Mitigation plan for each vulnerability
- Specific remediation timeline with tickets
- Request individual exceptions per vulnerability with appropriate duration

The platform team is available to help prioritize and address these vulnerabilities."