# Analysis Hints

If you're stuck, consider these questions:

## Severity Classification

**Critical/High vulnerabilities:** Should these ever be allowed in production?
- jsonwebtoken 8.5.1: JWT bypass (authentication broken)
- axios 0.21.1: SSRF (server can be tricked into making internal requests)

**Moderate vulnerabilities:** Should these block immediately or allow with warning?
- lodash 4.17.20: Prototype pollution (exploitable but requires specific conditions)
- moment 2.29.1: ReDoS (denial of service, not data breach)

## License Issues

**GPL-3.0:** This license requires your entire codebase to be open-sourced
- Should proprietary software ever include GPL dependencies?
- Is this a BLOCK or a WARN?

## Deprecation vs Maintenance Mode

**Deprecated:** Package explicitly marked as deprecated, maintainers recommend alternatives
**Maintenance mode:** Still receives critical security fixes but no new features

- moment: Maintenance mode (security fixes only)
- Should this BLOCK or WARN?

## Version Regressions

**Downgrades:** Going from a newer to an older version
- lodash: 4.17.21 → 4.17.20 (downgrade to vulnerable version)
- axios: 1.6.0 → 0.21.1 (major downgrade, introduces vulnerability)
- jsonwebtoken: 9.0.2 → 8.5.1 (major downgrade, introduces critical vulnerability)

Should version regressions ever be allowed automatically?

## Good Updates

Not everything is bad:
- express: 4.18.2 → 4.19.2 (security patches, good update)
- validator: 13.11.0 → 13.12.0 (minor version, likely safe)
- uuid: 9.0.0 → 9.0.1 (patch version, likely safe)
- dotenv: 16.3.1 → 16.4.5 (minor versions, check for issues)
- winston: 3.11.0 → 3.13.0 (minor versions, check for issues)

How do you distinguish good updates from problematic ones?

## Recommended Severity Thresholds

Different organizations use different thresholds:

**Conservative (high security):**
- Block: High, Critical
- Warn: Moderate, Low

**Balanced:**
- Block: Critical
- Warn: High, Moderate, Low

**Aggressive (fast iteration):**
- Block: None (rely on warnings and scheduled fixes)
- Warn: All severities

What threshold makes sense for Teriana Harvest?