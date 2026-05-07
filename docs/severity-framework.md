# Policy Severity Framework

This document explains Teriana Harvest's policy severity model and the criteria for deciding when violations should block deployment versus generate warnings.

## The Two Severity Levels

### BLOCK (Deployment Fails)
Violations that create immediate security risk, cause reliability failures under load, or violate compliance requirements.

### WARN (Deployment Succeeds, Issue Flagged)
Violations that create technical debt or suboptimal configurations but won't cause immediate incidents.

## Decision Criteria

### 1. Security Impact
**BLOCK if:**
- Violates least privilege (overly broad permissions)
- Creates credential exposure risk
- Enables privilege escalation
- Exposes data to unauthorized access

**WARN if:**
- Reduces security observability
- Missing security labels or metadata
- Suboptimal but not vulnerable configuration

### 2. Reliability Impact
**BLOCK if:**
- Can cause resource exhaustion (missing memory limits)
- Creates cascading failures (unbounded resource consumption)
- Breaks under normal production load

**WARN if:**
- Degrades reliability only under specific failure conditions
- Reduces availability during deployments but not steady-state
- Affects observability of failures

### 3. Blast Radius
**BLOCK if:**
- Affects multiple services or entire nodes
- Impacts all users or large user segments
- Cascades to dependent systems

**WARN if:**
- Scoped to single service
- Affects small user subset
- Isolated failure domain

### 4. Reversibility
**BLOCK if:**
- Requires significant rework to fix in production
- Needs security review or compliance approval
- Can't be fixed without redeployment

**WARN if:**
- Can be fixed via rolling update
- Can be added without code changes
- Easy to remediate post-deployment

### 5. Time to Incident
**BLOCK if:**
- Fails immediately or under normal load
- Exploitable immediately upon deployment
- Violates active compliance requirements

**WARN if:**
- Only fails under specific conditions
- Requires attacker sophistication to exploit
- Best practice violation, not requirement

## Applied to Our Policies

### BLOCK (5 policies)

**resource-limits.rego** - Missing memory limits
- Can crash neighboring pods immediately under load
- Blast radius: entire node
- Not reversible without redeployment

**owner-role.rego** - Owner role assignments
- Enables privilege escalation
- Blast radius: entire subscription if compromised
- Requires security review to fix

**iam-scope.rego** - Subscription-level permissions
- Violates least privilege immediately
- Blast radius: all subscription resources
- Security risk on day one

**storage-keys.rego** - Connection strings instead of managed identity
- Credentials can leak in logs, app settings
- Cannot be scoped or safely rotated
- Security risk from deployment

**network-rules.rego** - Missing storage network restrictions
- Exposes data to internet by default
- Blast radius: all data in storage account
- Immediate security exposure

### WARN (7 policies)

**liveness-probe.rego** - Missing liveness probe
- Only matters when container becomes unresponsive
- Blast radius: only this service
- Can be added via rolling update

**readiness-probe.rego** - Missing readiness probe
- Only causes issues during rolling updates
- Blast radius: brief traffic errors
- Easy to add post-deployment

**image-tags.rego** - Using :latest tag
- Creates unpredictability, not immediate failure
- Blast radius: affects reproducibility
- Can be pinned anytime

**metadata-labels.rego** - Missing labels
- Only affects observability and organization
- Blast radius: monitoring gaps
- Trivial to add

**cpu-requests.rego** - Missing CPU requests
- Suboptimal scheduling, not failure
- Blast radius: inefficient placement
- Easy to add

**replica-count.rego** - Single replica
- Only risky during updates or failures
- Blast radius: temporary unavailability
- Replica count easily increased

**pod-disruption-budget.rego** - Missing PDB
- Only matters during cluster maintenance
- Blast radius: specific maintenance windows
- Can be added independently

## Key Principles

1. **Security violations block.** Privilege escalation, credential exposure, and excessive permissions are always BLOCK.

2. **Resource exhaustion blocks.** Configurations that can crash nodes or cascade failures are BLOCK.

3. **Best practices warn.** Configurations that violate best practices but won't cause immediate incidents are WARN.

4. **Reversibility matters.** If it's easy to fix post-deployment and low-risk until fixed, it can warn.

5. **Compliance is context-dependent.** If your organization has regulatory requirements around certain configurations, those become BLOCK regardless of technical risk.

## Testing Your Severity Decisions

Ask these questions:

1. If this reaches production, when does it become a problem?
   - Immediately → BLOCK
   - Only under specific conditions → consider WARN

2. What's the blast radius?
   - Multiple services/systems → BLOCK
   - Single service → consider WARN

3. How hard is it to fix?
   - Requires redeployment or security review → BLOCK
   - Rolling update or config change → consider WARN

4. Is this a security violation?
   - Yes → probably BLOCK
   - Best practice → probably WARN

5. Does your compliance framework require this?
   - Yes → BLOCK
   - No → evaluate on technical merit