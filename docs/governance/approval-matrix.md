# Infrastructure Approval Matrix

Teriana Harvest uses risk-based approval gates for infrastructure changes. Approval requirements scale with change scope and blast radius.

## Approval Tiers

### Tier 1: Standard Changes
**Scope:** Configuration updates, scaling operations, non-breaking changes
**Required Approvals:** 1 Platform Engineer
**Example Changes:**
- Adding tags to resources
- Increasing VM sizes or replica counts
- Updating application settings (non-sensitive)
- Adding monitoring dashboards

**Automatic Approval Conditions:**
- No resource deletions
- No IAM changes
- No network rule modifications
- Terraform plan shows only updates (no creates/destroys)

---

### Tier 2: High-Risk Changes
**Scope:** Network modifications, new resource provisioning
**Required Approvals:** 
- 1 Network Team Lead (for network changes)
- 1 Platform Engineering Manager

**Example Changes:**
- Modifying firewall rules
- Creating new subnets or VNets
- Changing NSG configurations
- Adding new services or resources

**Review Requirements:**
- Network diagram updated
- Change documented in Confluence
- Rollback plan defined

---

### Tier 3: Critical Changes
**Scope:** IAM, data resources, security controls
**Required Approvals:**
- 1 Security Team Lead
- 1 Platform Engineering Manager
- Cannot be same person who opened the PR

**Example Changes:**
- Creating or modifying role assignments
- Granting Contributor or Owner roles
- Creating storage accounts or databases
- Modifying encryption settings
- Changing authentication mechanisms

**Review Requirements:**
- Security review completed
- Compliance impact assessed
- Least privilege verified
- Audit logging enabled

---

### Tier 4: Emergency Changes
**Scope:** Incident response, outage mitigation
**Required Approvals:**
- 1 On-call Platform Engineer
- Post-deployment review required within 24 hours

**Example Changes:**
- Emergency scaling during outage
- Temporary security rule bypass (must be reverted)
- Incident mitigation infrastructure changes

**Process:**
- Create incident ticket
- Document justification
- Deploy with on-call approval
- Schedule follow-up review
- Revert temporary changes within 48 hours

## Governance-as-Code Implementation

```yaml
# .github/governance/approval-rules.yml
rules:
  - name: iam-changes
    condition: |
      resource_changes.any(type.contains("role_assignment") || 
                          type.contains("role_definition"))
    tier: critical
    required_reviewers:
      - team: security-leads
      - team: platform-managers
    prevent_self_approval: true
    
  - name: network-changes
    condition: |
      resource_changes.any(type.contains("network") || 
                          type.contains("firewall") ||
                          type.contains("nsg"))
    tier: high
    required_reviewers:
      - team: network-leads
      - team: platform-managers
    
  - name: data-resources
    condition: |
      resource_changes.any(type.contains("storage") || 
                          type.contains("database") ||
                          type.contains("sql"))
    tier: critical
    required_reviewers:
      - team: security-leads
      - team: platform-managers
    prevent_self_approval: true
    
  - name: standard-changes
    condition: |
      !matches("iam-changes") && 
      !matches("network-changes") && 
      !matches("data-resources")
    tier: standard
    required_reviewers:
      - team: platform-engineers
        count: 1
```

## Stack Dependencies

Some infrastructure changes require coordinated approvals across teams:

**Example: Adding a new microservice**
1. Network team approves subnet and NSG rules
2. Platform team approves compute resources
3. Security team approves IAM roles
4. All approvals must complete before deployment

**Implementation:**
```yaml
dependencies:
  - name: new-service-infrastructure
    stacks:
      - network-stack:
          approvers: [network-leads]
      - compute-stack:
          depends_on: [network-stack]
          approvers: [platform-engineers]
      - iam-stack:
          depends_on: [compute-stack]
          approvers: [security-leads]
    
    deployment_order:
      - network-stack
      - compute-stack
      - iam-stack
```

## Observability Integration

Deployments automatically pause if system health degrades:

**Datadog Monitor Integration:**
- Critical monitors alerting → Deployment blocked
- Error rate > 1% → Deployment blocked  
- P99 latency > 500ms → Deployment blocked
- Active PagerDuty incidents → Deployment blocked

**ServiceNow Change Management:**
- High-risk changes create automatic change requests
- ServiceNow evaluates:
  - Change window compliance
  - Conflict with other changes
  - Required approvals collected
- Auto-approves or blocks based on organizational policy

## Audit Trail

All approvals logged to:
- GitHub deployment history
- Terraform state metadata
- External audit system (Splunk)

Audit entries include:
- Who approved
- When approved
- Risk tier
- Changes approved
- Justification (for emergency changes)

## Exception Process

**When to request exception:**
- Business-critical deployment outside change window
- Emergency fix requires bypassing standard approval
- Approval chain blocked but deployment cannot wait

**Exception requestors:**
- VP Engineering
- CTO
- Director of Platform Engineering

**Exception requirements:**
- Documented justification
- Incident ticket reference
- Post-deployment review scheduled
- Root cause analysis committed

All exceptions reviewed monthly by engineering leadership.