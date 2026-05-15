# Issues for Students to Find (Reference)

This document lists the issues intentionally placed in the AI-generated code. Students should find these through guardrail application.

## Section 3: Policy-as-Code Issues

### Kubernetes
- ❌ Missing resource requests and limits
- ❌ Missing liveness probe
- ❌ Missing readiness probe
- ❌ Single replica (no high availability)
- ❌ No PodDisruptionBudget
- ❌ No security context (runs as root)

### Terraform
- ❌ Storage account has no network restrictions
- ❌ Container has public blob access
- ❌ IAM role is subscription-wide Contributor (too broad)
- ❌ Hardcoded password in code
- ❌ No Key Vault access policy

## Section 4: Infrastructure Change Issues

- ❌ Terraform creates new database (could cause data loss if replacing existing)
- ❌ No approval workflow for infrastructure changes
- ❌ No plan validation before apply

## Section 5: Kubernetes Security Issues

- ❌ Container runs as root (Dockerfile has no USER directive)
- ❌ No security context in deployment
- ❌ No resource limits (can crash node)
- ❌ No health probes (can't detect failures)
- ❌ Single replica (no redundancy)

## Section 6: Supply Chain Issues

### Dependencies
- ❌ lodash 4.17.20 - CVE-2020-8203 (Prototype Pollution) - HIGH
- ❌ axios 0.21.1 - CVE-2021-3749 (SSRF) - HIGH
- ❌ jsonwebtoken 8.5.1 - CVE-2022-23529 (JWT bypass) - CRITICAL
- ❌ moment 2.29.1 - Maintenance mode + CVE (ReDoS) - MODERATE

### Other
- ❌ No SBOM generated
- ❌ No license compliance check
- ❌ No deprecation detection

## Section 7: Progressive Delivery Issues

- ❌ No canary deployment configured
- ❌ No automated health checks during rollout
- ❌ No rollback triggers
- ❌ Deployment goes straight to 100% (all-or-nothing)

## Section 8: Exception Governance

If students need exceptions:
- Must document why
- Must get appropriate approval
- Must set time limit
- Must create remediation plan

Possible exceptions:
- TensorFlow.js might need higher memory limits
- ML model loading might need longer startup time

## Section 9: Feedback Loops

- Should log guardrail failures
- Should detect AI-generated patterns
- Should generate guidance for future
- Should measure effectiveness

## Total Issues: ~25+

Students should find and address most/all of these through guardrail application.