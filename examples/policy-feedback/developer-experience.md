# Policy Feedback Developer Experience

## Scenario: Developer deploys Kubernetes manifest with missing resource limits

### Bad Experience (Vague Message)

**Pipeline Output:**
❌ Policy violation: resource limits

**Developer's Questions:**
- Which container?
- Which resource? Memory? CPU?
- What value should I use?
- Where in the manifest should I add it?

**Time to Fix:** 5-10 minutes (search docs, find examples, guess values)

---

### Good Experience (Actionable Message)

**Pipeline Output:**

❌ Container 'sensor-processor' missing memory limit.
Add to manifest:
resources:
limits:
memory: '512Mi'
Recommended values: 256Mi (small), 512Mi (medium), 1Gi (large)

**Developer's Actions:**
1. Copy suggested configuration
2. Paste into manifest at correct location
3. Choose appropriate value for service size
4. Commit and push

**Time to Fix:** 30 seconds

---

## Impact at Teriana Harvest

**Before actionable feedback:**
- Average time to fix policy violation: 8 minutes
- 40% of fixes required help from platform team
- Developers frustrated with "policy as gatekeeping"

**After actionable feedback:**
- Average time to fix: 45 seconds
- 5% require platform team help (genuinely complex cases)
- Developers view policies as helpful guardrails