# Risky Infrastructure Changes

These examples demonstrate infrastructure changes that should trigger review or block deployment.

## Risky Patterns

### 1. Resource Deletion (`delete-storage.tf`)
Removing a resource entirely causes Terraform to destroy it. For stateful resources like storage accounts or databases, this means data loss.

### 2. Region Changes (`change-region.tf`)
Changing the region forces resource replacement. Data must be migrated, and there will be downtime.

### 3. Removing Network Restrictions (`remove-network-rules.tf`)
Removing network rules opens resources to public internet access. Security risk.

### 4. Capacity Reduction (`reduce-capacity.tf`)
Downgrading SKUs or reducing capacity can cause performance degradation or availability issues.

## Detection

The validation scripts in `scripts/infrastructure-validation/` analyze Terraform plans to detect:
- Resource deletions (block deployment)
- Resource replacements (require approval)
- Breaking configuration changes (block deployment)
- Performance downgrades (warning)

## Safe Changes

See `examples/safe-changes/` for changes that don't require special review:
- Adding tags
- Increasing capacity
- Adding optional configuration
- Non-breaking updates