# Policy-as-Code Validation

This directory contains OPA (Open Policy Agent) policies that validate Teriana Harvest infrastructure and application configurations.

## Policies

### Kubernetes (`kubernetes/`)
- `resource-limits.rego` - Enforces memory limits and CPU requests on all containers
- `health-probes.rego` - Requires liveness and readiness probes on all deployments

### Terraform (`terraform/`)
- `iam-least-privilege.rego` - Prevents overly broad IAM role assignments
- Validates storage account security settings

## Testing Policies

Run the validation script:

```bash
chmod +x scripts/validate-policies.sh
./scripts/validate-policies.sh
```

This runs all policies against example configurations in `examples/`.

## Integration

These policies run in the CI pipeline via the `policy-validation` job in `.github/workflows/ci.yml`.