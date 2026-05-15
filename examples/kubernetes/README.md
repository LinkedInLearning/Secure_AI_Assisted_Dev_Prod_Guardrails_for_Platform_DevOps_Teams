# Kubernetes Deployment Examples

## Unsafe Configurations

The `unsafe/` directory contains common misconfigurations that create security or reliability risks:

- **no-limits.yaml** - Missing resource limits (can crash node)
- **no-probes.yaml** - Missing health probes (can't detect failures)
- **privileged.yaml** - Privileged container (can escape to host)
- **single-replica.yaml** - Single replica in production (no redundancy)

## Safe Configurations

The `safe/` directory shows proper configurations:

- **with-limits.yaml** - Resource limits and requests configured
- **with-probes.yaml** - Liveness and readiness probes
- **unprivileged.yaml** - Secure container with dropped capabilities
- **high-availability.yaml** - Multiple replicas with PodDisruptionBudget

## Validation

Run policy validation:
```bash
./scripts/kubernetes-validation/validate-deployments.sh
```

This checks all manifests against security policies in `policies/pod-security/`.