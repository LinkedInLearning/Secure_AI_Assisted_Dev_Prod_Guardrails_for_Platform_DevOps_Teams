package kubernetes.healthprobes

# Deny deployments without liveness probe
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf("Container '%s' missing liveness probe", [container.name])
}

# Deny deployments without readiness probe
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf("Container '%s' missing readiness probe", [container.name])
}