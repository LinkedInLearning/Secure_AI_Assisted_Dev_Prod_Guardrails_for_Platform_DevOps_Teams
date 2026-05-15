package kubernetes.pod_security.resources

# POLICY: All containers must have resource limits
# SEVERITY: BLOCK
# REASONING: Prevents resource exhaustion and node crashes

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    
    msg := sprintf(
        "Container '%s' in deployment '%s' missing memory limit.\n\nAdd:\nresources:\n  limits:\n    memory: '512Mi'\n\nWithout limits, container can exhaust node memory.",
        [container.name, input.metadata.name]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    
    msg := sprintf(
        "Container '%s' in deployment '%s' missing CPU limit.\n\nAdd:\nresources:\n  limits:\n    cpu: '500m'\n\nWithout limits, container can starve other pods.",
        [container.name, input.metadata.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
    
    msg := sprintf(
        "Container '%s' missing memory request.\n\nScheduler cannot make informed placement decisions.",
        [container.name]
    )
}