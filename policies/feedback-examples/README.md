# Policy Feedback Examples

This directory demonstrates the difference between unhelpful and actionable policy error messages.

## Bad Feedback Patterns

Files ending in `-bad.rego`:
- Vague error messages
- No context about what's wrong
- No guidance on how to fix
- Developer must search documentation

## Good Feedback Patterns

Files ending in `-good.rego`:
- Specific error messages identifying the exact issue
- Explains WHY it's a problem (security, reliability)
- Shows HOW to fix it with code snippets
- Provides recommended values or alternatives

## Key Principles

**Be Specific:**
- Bad: "Policy violation"
- Good: "Container 'sensor-processor' missing memory limit"

**Show the Fix:**
- Bad: "Add resource limits"
- Good: "resources:\n  limits:\n    memory: '512Mi'"

**Explain Why:**
- Bad: "Invalid configuration"
- Good: "Grants access to ALL resources - security risk"

**Provide Context:**
- Bad: "Change image tag"
- Good: "Current: :latest → Change to: :v1.2.3"