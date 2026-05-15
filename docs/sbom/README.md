# Software Bill of Materials (SBOM)

An SBOM is a complete inventory of all software components, dependencies, and metadata for an application.

## Why We Generate SBOMs

### 1. Vulnerability Response
When a new CVE is disclosed, we can instantly check which applications are affected:
```bash
./scripts/sbom/query-vulnerability.sh CVE-2021-3749 axios '<0.21.2'
```

Returns:
- sensor-data-api v2.0.5 uses axios@0.21.1 ✗ AFFECTED
- sensor-data-api v2.1.0 uses axios@1.7.2 ✓ NOT AFFECTED

### 2. License Compliance
Auditors can verify all dependencies and their licenses without accessing source code.

### 3. Supply Chain Security
SBOMs create an auditable record of what went into each build. If a dependency is compromised, we know exactly which releases are affected.

### 4. Regulatory Requirements
Executive Order 14028 (US Federal) and similar regulations require SBOMs for software sold to government.

## SBOM Formats

We generate multiple formats:

**CycloneDX (JSON/XML):** Modern, lightweight, supports vulnerability data
**SPDX (JSON):** ISO standard, broader industry adoption

## SBOM Lifecycle

### Generation
```bash
# Manual generation
./scripts/sbom/generate-sbom.sh sensor-data-api 2.1.0

# Automatic in CI/CD
# - Every push to main
# - Every release
```

### Storage
```
sbom/storage/
├── sensor-data-api/
│   ├── 2.0.5/
│   │   ├── sensor-data-api-2.0.5-cyclonedx.json
│   │   ├── sensor-data-api-2.0.5-cyclonedx.json.asc (signature)
│   │   └── sensor-data-api-2.0.5-summary.txt
│   ├── 2.1.0/
│   │   └── ...
│   ├── latest -> 2.1.0
│   └── versions.json
```

### Querying
```bash
# Check for vulnerable package
./scripts/sbom/query-vulnerability.sh CVE-2021-3749 axios '<0.21.2'

# List all versions with SBOMs
jq '.' sbom/storage/sensor-data-api/versions.json
```

## Real-World Example

**December 2021: Log4Shell (CVE-2021-44228)**

Without SBOM:
- Manually grep codebases for log4j references
- Check each application individually
- Takes days to get complete picture

With SBOM:
```bash
./scripts/sbom/query-vulnerability.sh \
  CVE-2021-44228 \
  log4j-core \
  '>=2.0-beta9 <2.15.0'
```

Results in seconds showing exactly which apps/versions are affected.

## SBOM Signing

SBOMs are GPG-signed to prevent tampering:
```bash
# Verify signature
gpg --verify sensor-data-api-2.1.0-cyclonedx.json.asc

# If signature valid, SBOM hasn't been modified since generation
```

## Integration with Security Tools

SBOMs can be ingested by:
- Dependency Track (vulnerability tracking)
- Grype (vulnerability scanning)
- FOSSA (license compliance)
- BlackDuck (supply chain risk)