# Supply Chain Enforcement Decisions

## Issue-by-Issue Analysis

### 1. lodash: 4.17.21 → 4.17.20 (DOWNGRADE)

**Issue:** Version regression + High severity CVE-2020-8203
**Severity:** High (Prototype Pollution)
**Decision:** **BLOCK**

**Reasoning:**
- Downgrading from a fixed version to a vulnerable version
- High severity vulnerability
- No legitimate reason to downgrade

**Policy:**
```yaml
vulnerability_policy:
  block_on_severity: [high, critical]

version_regression_policy:
  block_on_downgrade: true
```

---

### 2. axios: 1.6.0 → 0.21.1 (MAJOR DOWNGRADE)

**Issue:** Major version regression + High severity CVE-2021-3749
**Severity:** High (SSRF)
**Decision:** **BLOCK**

**Reasoning:**
- Major downgrade (1.x → 0.x)
- Server-Side Request Forgery allows internal network access
- High severity vulnerability
- PR says "downgrade for stability" but introduces security risk

**Policy:**
```yaml
vulnerability_policy:
  block_on_severity: [high, critical]

version_regression_policy:
  block_on_downgrade: true
```

---

### 3. jsonwebtoken: 9.0.2 → 8.5.1 (MAJOR DOWNGRADE)

**Issue:** Major version regression + Critical CVEs
**Severity:** Critical (JWT verification bypass)
**Decision:** **BLOCK**

**Reasoning:**
- Critical severity - authentication completely broken
- Attacker can forge JWTs and bypass authentication
- Major downgrade from secure version to vulnerable version
- Unacceptable in production

**Policy:**
```yaml
vulnerability_policy:
  block_on_severity: [critical, high]

version_regression_policy:
  block_on_downgrade: true
```

---

### 4. some-gpl-package: added 1.2.0

**Issue:** GPL-3.0 license
**Severity:** Legal violation
**Decision:** **BLOCK**

**Reasoning:**
- GPL-3.0 requires entire application to be open-sourced
- Teriana Harvest is proprietary software
- Legal compliance violation
- Must be removed immediately

**Policy:**
```yaml
license_policy:
  blocked_licenses:
    - GPL-3.0
```

---

### 5. moment: 2.29.1 (NEW DEPENDENCY)

**Issue:** Package in maintenance mode + Moderate CVE
**Severity:** Moderate (ReDoS)
**Decision:** **WARN**

**Reasoning:**
- Maintenance mode (security fixes only, no features)
- Moderate severity ReDoS vulnerability
- Team officially recommends migration to alternatives
- Should migrate but not critical enough to block immediately

**Policy:**
```yaml
vulnerability_policy:
  warn_on_severity: [moderate]

deprecation_policy:
  warn_maintenance_mode: true
```

**Follow-up Action:** Create ticket to migrate to date-fns

---

### 6. express: 4.18.2 → 4.19.2 (UPGRADE)

**Issue:** None
**Decision:** **ALLOW**

**Reasoning:**
- Security patches
- Minor version upgrade
- No vulnerabilities in 4.19.2
- Good update

---

### 7. validator: 13.11.0 → 13.12.0 (MINOR UPGRADE)

**Issue:** None
**Decision:** **ALLOW**

**Reasoning:**
- Minor version upgrade
- No known vulnerabilities
- Standard maintenance update

---

### 8. uuid: 9.0.0 → 9.0.1 (PATCH UPGRADE)

**Issue:** None
**Decision:** **ALLOW**

**Reasoning:**
- Patch version update
- Bug fixes only
- Safe update

---

### 9. dotenv: 16.3.1 → 16.4.5 (MINOR UPGRADE)

**Issue:** None
**Decision:** **ALLOW**

**Reasoning:**
- Minor version updates
- No known vulnerabilities
- Standard maintenance

---

### 10. winston: 3.11.0 → 3.13.0 (MINOR UPGRADE)

**Issue:** None
**Decision:** **ALLOW**

**Reasoning:**
- Minor version update
- No known vulnerabilities
- Standard maintenance

---

## Summary

| Change | Decision | Reason |
|--------|----------|--------|
| lodash downgrade | **BLOCK** | High CVE + regression |
| axios downgrade | **BLOCK** | High CVE + major regression |
| jsonwebtoken downgrade | **BLOCK** | Critical CVE + major regression |
| some-gpl-package added | **BLOCK** | License violation |
| moment added | **WARN** | Maintenance mode + moderate CVE |
| express upgrade | **ALLOW** | Security patches |
| validator upgrade | **ALLOW** | Safe minor update |
| uuid upgrade | **ALLOW** | Safe patch update |
| dotenv upgrade | **ALLOW** | Safe minor update |
| winston upgrade | **ALLOW** | Safe minor update |

**Blocking Issues:** 4
**Warnings:** 1
**Allowed:** 5

## Enforcement Configuration

```yaml
# Supply Chain Baseline
vulnerability_policy:
  block_on_severity: [critical, high]
  warn_on_severity: [moderate, low]

license_policy:
  blocked_licenses: [GPL-2.0, GPL-3.0, AGPL-3.0]

version_regression_policy:
  block_on_downgrade: true

deprecation_policy:
  block_deprecated: true
  warn_maintenance_mode: true
```

This configuration would have caught all 4 blocking issues and generated the maintenance mode warning.