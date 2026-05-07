# Uncategorized Policy Rules

These 12 policy rules need severity classification. For each rule, decide whether violations should **BLOCK** deployment or generate a **WARNING**.

## The Policies

1. **resource-limits.rego** - Missing memory limits on containers
2. **liveness-probe.rego** - Missing liveness probe
3. **image-tags.rego** - Using :latest tag instead of pinned version
4. **metadata-labels.rego** - Missing team/component labels
5. **iam-scope.rego** - Subscription-level role assignments
6. **owner-role.rego** - Owner role assignments (privilege escalation risk)
7. **network-rules.rego** - Storage account missing network restrictions
8. **storage-keys.rego** - Using connection strings instead of managed identity
9. **cpu-requests.rego** - Missing CPU requests
10. **readiness-probe.rego** - Missing readiness probe
11. **replica-count.rego** - Single replica deployments
12. **pod-disruption-budget.rego** - Missing PodDisruptionBudget

## Your Task

Categorize each policy:
- **BLOCK:** Violations that create immediate risk or compliance issues
- **WARN:** Violations that should be fixed but won't cause immediate incidents

Consider:
- Security impact
- Reliability impact  
- Blast radius
- Compliance requirements
- Reversibility

Document your reasoning for each decision.