# SBOM in Incident Response: Real Example

## Scenario: CVE-2021-3749 in axios

**Date:** August 31, 2021
**CVE:** CVE-2021-3749
**Package:** axios
**Vulnerability:** Server-Side Request Forgery (SSRF)
**Affected Versions:** <0.21.2
**Severity:** High

## Without SBOM (Traditional Approach)

**Timeline:**
- T+0: CVE disclosed
- T+2h: Security team notified
- T+4h: Start manual audit of codebases
- T+8h: Grep all repos for "axios"
- T+12h: Check package.json in 47 services
- T+24h: Find 12 services using axios
- T+26h: Check each service's axios version manually
- T+28h: Identify 8 services with vulnerable versions
- T+30h: Create update plan

**Total time to identify affected services: 30 hours**

## With SBOM (Our Approach)

**Timeline:**
- T+0: CVE disclosed
- T+2h: Security team notified
- T+2h+5min: Run SBOM query

```bash
./scripts/sbom/query-vulnerability.sh \
  CVE-2021-3749 \
  axios \
  '<0.21.2'
```

**Output:**
```
Checking for CVE-2021-3749 (axios <0.21.2)
Found: sensor-data-api v2.0.5 uses axios@0.21.1
Found: payment-processor v1.8.2 uses axios@0.21.0
Found: data-aggregator v1.2.1 uses axios@0.20.0
Found: notification-service v3.1.0 uses axios@0.21.1
========================================================
❌ 4 application(s) potentially affected:

sensor-data-api v2.0.5 (axios@0.21.1)
payment-processor v1.8.2 (axios@0.21.0)
data-aggregator v1.2.1 (axios@0.20.0)
notification-service v3.1.0 (axios@0.21.1)

Action required: Update axios to 0.21.2+
```

- T+2h+10min: Have complete list of affected services

**Total time to identify affected services: 10 minutes**

## Impact

| Metric | Without SBOM | With SBOM | Improvement |
|--------|-------------|-----------|-------------|
| Time to identify | 30 hours | 10 minutes | 180x faster |
| Manual effort | High | Minimal | Automated |
| Accuracy | Prone to missed services | Complete | 100% coverage |
| Confidence | Medium | High | Verifiable |

## What Happens Next

With the affected services identified in 10 minutes:

- T+2h+15min: Create Jira tickets for each service
- T+2h+30min: Automated PRs created by Dependabot
- T+4h: First service updated and deployed
- T+12h: All services patched

**Mean Time to Remediation (MTTR): 12 hours**

Without SBOM, we'd still be identifying affected services at the 12-hour mark.

## Key Insight

The SBOM doesn't prevent the vulnerability. It enables rapid response. 

The difference between 30 hours and 10 minutes matters when:
- Vulnerabilities are actively exploited
- Compliance deadlines are measured in hours
- Competitive pressure exists to patch quickly