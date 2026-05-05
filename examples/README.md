# Workflow Security Examples

This directory contains examples of workflow attacks and defenses discussed in Chapter 2, Video 2.

## Attack Patterns (`workflow-attacks/`)

Examples of how AI-generated code might weaken CI/CD pipelines:

- `conditional-bypass.yml` - Skipping checks for certain branches
- `reordered-steps.yml` - Deploying before security validation
- `loosened-approval.yml` - Unsafe use of pull_request_target
- `test-skip.yml` - Allowing test skips via commit messages

**These are examples of what NOT to do.**

## Defense Patterns (`workflow-defenses/`)

Examples of how to protect workflows:

- `validate-workflows.yml` - Automated validation of workflow changes
- `required-checks.yml` - Properly structured job dependencies

## Defense Files (Root Level)

- `/CODEOWNERS` - Requires platform team approval for workflow changes