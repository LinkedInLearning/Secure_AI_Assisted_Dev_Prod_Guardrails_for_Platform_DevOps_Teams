# Supply Chain Security

Teriana Harvest uses automated scanning to detect risky dependencies introduced by AI tools or human developers.

## The Problem with AI-Generated Dependencies

When you ask an AI assistant for code, it often suggests dependencies based on:
- **Training data patterns** (what was popular when the model was trained)
- **Popularity** (packages that appear frequently in code examples)
- **Functionality match** (packages that solve the problem)

AI assistants DON'T consider:
- **Current vulnerabilities** (CVEs disclosed after training)
- **Deprecation status** (packages that are no longer maintained)
- **License compatibility** (GPL vs MIT vs Apache)
- **Supply chain attacks** (malicious packages, typosquatting)

## Our Scanning Strategy

### 1. Dependency Vulnerability Scanning
**Tools:** npm audit, Snyk, Dependabot
**Frequency:** Every PR, daily scheduled scans
**Action:** Block deployment on high/critical vulnerabilities

### 2. License Compliance
**Tools:** license-checker
**Frequency:** Every PR
**Action:** Block deployment on GPL licenses (incompatible with proprietary code)

### 3. Outdated Package Detection
**Tools:** npm outdated, Dependabot
**Frequency:** Weekly
**Action:** Create PRs for updates, warn but don't block

### 4. SBOM Generation
**Tools:** CycloneDX
**Frequency:** Every build
**Action:** Generate Software Bill of Materials for compliance and auditing

## Running Scans Locally

```bash
# Quick validation
./scripts/supply-chain/validate-dependencies.sh

# Individual scans
npm audit
npm outdated
npx license-checker --summary
npx @cyclonedx/cyclonedx-npm --output-file sbom.json
```

## CI/CD Integration

All scans run automatically in `.github/workflows/supply-chain-security.yml`:
- PR checks block merge on critical vulnerabilities
- Daily scheduled scans catch newly disclosed CVEs
- Dependabot creates automatic update PRs

## Example Vulnerabilities Caught

See `examples/risky-dependencies/VULNERABILITIES.md` for real examples of vulnerable dependencies suggested by AI tools.