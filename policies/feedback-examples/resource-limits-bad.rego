package kubernetes.resourcelimits

# BAD: Unhelpful error message
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := "Policy violation: resource limits"
}