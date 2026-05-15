# Capstone Challenge: Ship AI-Generated Service Safely

## Overview

This directory contains an AI-generated crop yield prediction service. The code is functional but hasn't been through any guardrails. Your job is to apply all guardrails learned in the course to ship it safely.

## Directory Structure
```
services/crop-yield-predictor/    - Application code
deployments/crop-yield-predictor/ - Kubernetes manifests
infrastructure/crop-yield-predictor/ - Terraform code
docs/capstone/                    - Documentation
```

## The Challenge

Apply guardrails from:
1. Section 3: Policy-as-code validation
2. Section 4: Infrastructure change validation
3. Section 5: Kubernetes pod security
4. Section 6: Supply chain guardrails
5. Section 7: Progressive delivery
6. Section 8: Exception governance
7. Section 9: Feedback loops

## Getting Started

1. Review the AI generation notes
2. Scan the code for potential issues
3. Apply guardrails systematically
4. Document findings and fixes
5. Configure safe deployment

## What to Look For

- Security vulnerabilities
- Missing safety configurations
- Insecure defaults
- Supply chain risks
- Deployment risks
- Need for exceptions

## Success Criteria

- All guardrails applied
- Issues identified and fixed or excepted
- Safe deployment path configured
- Metrics and feedback in place
- Documentation complete