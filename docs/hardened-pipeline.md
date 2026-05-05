# Hardened Pipeline Implementation

This branch demonstrates a properly hardened CI/CD pipeline that prevents validation bypass.

## What Was Fixed

### 1. Removed Conditional Bypasses
- **Before:** Jobs skipped for `hotfix/*` branches
- **After:** All jobs run unconditionally on every PR and push

### 2. Eliminated Test Skip Flags
- **Before:** Tests could be skipped with `[skip-tests]` in commit message
- **After:** Tests always run, no skip patterns allowed

### 3. Added Explicit Job Dependencies
- **Before:** Deploy job only waited for terraform validation
- **After:** Deploy requires ALL jobs to pass: `needs: [sensor-api, security, terraform]`

### 4. Protected Workflow Files
- Added CODEOWNERS requiring platform team approval for workflow changes
- Added automated validation that scans for dangerous patterns
- Workflow changes now trigger security validation job

## Defense Mechanisms

**CODEOWNERS Enforcement:**
Workflow files require approval from `@teriana-harvest/platform-team` before merge.

**Automated Validation:**
The `validate-workflows.yml` job runs on every PR that touches workflow files and checks for:
- Conditional bypasses (hotfix, emergency branches)
- Test skip patterns
- Unsafe workflow triggers
- Missing job dependencies on deploy jobs

**Job Dependencies:**
Deploy jobs explicitly list all required validation jobs in `needs` clause, making the execution order visible and enforceable.

## Testing the Protections

Try to introduce these weaknesses and watch them get caught:

```yaml
# This will fail validation
if: ${{ startsWith(github.head_ref, 'hotfix/') }}
```

```yaml
# This will fail validation
if: ${{ contains(github.event.head_commit.message, '[skip-tests]') }}
```

```yaml
# This will fail validation
deploy:
  needs: [terraform]  # Missing sensor-api and security
```

All three patterns will be caught by automated validation before merge.