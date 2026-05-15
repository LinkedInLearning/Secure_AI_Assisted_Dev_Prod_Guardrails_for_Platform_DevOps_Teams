# Exception Request: ML Model Resource Limits

## Exception Details

**Service:** crop-yield-predictor
**Guardrail:** Resource limits policy
**Issue:** ML model loading requires 2Gi memory, exceeds standard 512Mi limit

## Justification

TensorFlow.js model loading requires significant memory:
- Model file: 850MB
- Runtime memory: ~1.2GB during inference
- Standard limit of 512Mi is insufficient

## Risk Assessment

**Risk:** Higher memory allocation increases blast radius if memory leak occurs
**Mitigation:**
- Memory limit set to 2Gi (not unlimited)
- Health probes configured to detect leaks
- Horizontal scaling with 3 replicas limits impact per pod

## Duration

**Requested:** 90 days (permanent for this service)
**Justification:** ML models inherently require more memory than standard services

## Remediation Plan

N/A - This is a legitimate architectural requirement for ML services

## Approval

**Approved by:** @platform-lead
**Approval date:** 2026-05-16
**Status:** Active
**Review date:** 2026-08-16 (quarterly review)