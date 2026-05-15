# PR #1523 Dependency Analysis

This PR was merged on 2026-05-14. Two days later, security scanners flagged critical issues.

## All Dependency Changes

### 1. express: 4.18.2 → 4.19.2
**Change Type:** Upgrade
**Reason:** Security patches
**Status:** ✅ Good

### 2. lodash: 4.17.21 → 4.17.20
**Change Type:** Downgrade
**Reason:** "Standardize version"
**Status:** ❓ Analyze this

### 3. date-fns: removed, moment: 2.29.1 added
**Change Type:** Replacement
**Reason:** "Better date formatting APIs"
**Status:** ❓ Analyze this

### 4. axios: 1.6.0 → 0.21.1
**Change Type:** Major downgrade
**Reason:** "Downgrade for stability"
**Status:** ❓ Analyze this

### 5. validator: 13.11.0 → 13.12.0
**Change Type:** Minor upgrade
**Reason:** Latest version
**Status:** ❓ Analyze this

### 6. uuid: 9.0.0 → 9.0.1
**Change Type:** Patch upgrade
**Reason:** Patch update
**Status:** ❓ Analyze this

### 7. jsonwebtoken: 9.0.2 → 8.5.1
**Change Type:** Major downgrade
**Reason:** "Downgrade for compatibility"
**Status:** ❓ Analyze this

### 8. dotenv: 16.3.1 → 16.4.5
**Change Type:** Minor upgrade
**Reason:** Latest version
**Status:** ❓ Analyze this

### 9. winston: 3.11.0 → 3.13.0
**Change Type:** Minor upgrade
**Reason:** Latest version
**Status:** ❓ Analyze this

### 10. some-gpl-package: added 1.2.0
**Change Type:** New dependency
**Reason:** "Data visualization"
**Status:** ❓ Analyze this

## Your Task

For each change marked with ❓, determine:

1. **Is there a security issue?**
   - Check for known CVEs
   - Check deprecation status
   - Check maintenance status

2. **Is there a license issue?**
   - Check license compatibility
   - Identify GPL or other restrictive licenses

3. **Should this BLOCK or WARN?**
   - BLOCK: Critical security, license violations, deprecated packages
   - WARN: Lower severity issues, technical debt, suboptimal choices

4. **What policy catches this?**
   - Vulnerability scanner threshold
   - License compliance rules
   - Deprecation detection
   - Version regression detection

## Known Issues (Hidden in Challenge)

**Security Scanner Results:**
```
npm audit
found 8 vulnerabilities (3 moderate, 3 high, 2 critical)

lodash  4.17.20
Severity: high
Prototype Pollution
Fixed in: 4.17.21

axios  0.21.1
Severity: high
Server-Side Request Forgery (SSRF)
Fixed in: 0.21.2

jsonwebtoken  8.5.1
Severity: critical
JWT verification bypass
Fixed in: 9.0.0

moment  2.29.1
Severity: moderate
ReDoS vulnerability
Status: MAINTENANCE MODE - recommend migration to alternatives
```

**License Scanner Results:**

```
some-gpl-package: GPL-3.0
Risk: Requires entire application to be open-sourced
Impact: Legal violation for proprietary software
```

**Deprecation Scanner Results:**
```
moment: Maintenance mode since 2020
Recommendation: Use date-fns, dayjs, or luxon
```

## Questions to Answer

1. Which of these changes should have BLOCKED deployment?
2. Which should have generated WARNINGS?
3. What severity threshold makes sense for blocking?
4. Should downgrading a package ever be allowed automatically?
5. How do you handle transitive vulnerabilities vs direct dependencies?
6. What tooling configuration would catch all these issues?