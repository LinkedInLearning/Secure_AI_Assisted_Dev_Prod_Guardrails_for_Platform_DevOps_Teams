package kubernetes.resourcelimits

# Deny pods without memory limits
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf("Container '%s' missing memory limit", [container.name])
}

# Deny pods without CPU requests
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf("Container '%s' missing CPU request", [container.name])
}