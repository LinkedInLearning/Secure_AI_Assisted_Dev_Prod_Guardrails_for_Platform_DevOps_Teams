# Challenge: Vulnerable Dependency Introduced

## Scenario

A developer merged PR #1523 updating dependencies. The changes looked reasonable:
- Upgraded express for security patches
- Added moment for date formatting
- Updated other packages to "latest versions"

But the PR introduced:
- 3 high-severity vulnerabilities
- 2 critical-severity vulnerabilities
- 1 license violation
- 1 package in maintenance mode

## Your Task

Analyze the dependency changes and determine:

1. **What should BLOCK deployment?**
   - Which vulnerabilities are too severe?
   - Which license issues create legal risk?
   - Which patterns must be prevented?

2. **What should WARN?**
   - Which issues need attention but aren't emergencies?
   - Which technical debt should be tracked?

3. **What policies prevent this?**
   - Vulnerability scanning thresholds
   - License compliance rules
   - Version regression detection
   - Deprecation warnings

## Files to Review

- `PR_DESCRIPTION.md` - Original PR description
- `ANALYSIS.md` - Detailed breakdown of each change
- `HINTS.md` - Questions to guide your analysis

## Success Criteria

You should identify:
- All security vulnerabilities and their severities
- License compatibility issues
- Deprecated/maintenance mode packages
- Version regressions that introduce risks
- Clear BLOCK vs WARN policies for each category