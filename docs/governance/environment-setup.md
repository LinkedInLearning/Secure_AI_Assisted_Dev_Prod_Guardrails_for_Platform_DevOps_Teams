# GitHub Environment Configuration

Teriana Harvest uses GitHub Environments to enforce deployment governance. Environments cannot be configured via YAML - they must be set up in the GitHub UI.

## Staging Environment

**Path:** Settings > Environments > staging

**Configuration:**
- Required reviewers: None (auto-deploy)
- Wait timer: 0 minutes
- Deployment branches: Any branch
- Secrets: Staging-specific credentials

**Purpose:** Automated testing environment for infrastructure changes before production.

## Production Environment

**Path:** Settings > Environments > production

**Configuration:**

### Required Reviewers
- Minimum: 1 reviewer
- Prevent self-approval: Enabled
- Reviewer teams configured based on change type (see approval-matrix.md)

### Wait Timer
- 5 minutes (cooling-off period)
- Allows time to catch accidental deployments

### Deployment Branches
- Restricted to: `main` branch only
- Prevents accidental production deploys from feature branches

### Custom Protection Rules

**1. Observability Gate**
- GitHub App: teriana-observability-gate
- Checks: Datadog monitors, error rates, active incidents
- Timeout: 2 minutes
- Bypass: Requires VP Engineering approval

**2. Change Management Gate** (Future)
- GitHub App: servicenow-integration
- Checks: Change window compliance, conflict detection
- Timeout: 1 minute
- Bypass: Requires CTO approval

### Environment Secrets
Production-specific secrets stored at environment level:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `TERRAFORM_BACKEND_KEY`

Secrets only accessible after approval granted.

## Setting Up a New Environment

GitHub Environments must be configured manually through the UI. Here's the process:

1. Navigate to: Settings > Environments
2. Click "New environment"
3. Name the environment (e.g., "production")
4. Click "Configure environment"
5. Add protection rules:
   - Required reviewers: Add teams or individuals
   - Enable "Prevent self-review"
   - Set wait timer if needed
   - Configure deployment branches
6. Add environment secrets
7. Enable custom protection rules if configured

**Note:** GitHub does not support Infrastructure-as-Code for environment configuration. This is intentional - environments are governance controls and should require deliberate setup.

## Programmatic Access

While environment configuration requires UI setup, you can query environments via API:

```bash
# List environments
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/teriana/platform/environments

# Get environment details
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/teriana/platform/environments/production
```

## Migration from CODEOWNERS

Previous approach:
- CODEOWNERS file defined who could approve PRs
- All infrastructure changes required same approval
- No differentiation between low-risk and high-risk changes

New approach:
- Environment protection rules enforce deployment governance
- Risk-based approval tiers
- Integration with external systems
- Automatic approval for low-risk changes
- Graduated enforcement for different change types

**Key Difference:** CODEOWNERS gates PR merge. Environments gate deployment. You can merge a PR but still need deployment approval.