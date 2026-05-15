package kubernetes.reliability.resources

# POLICY: All containers must have resource limits
# SEVERITY: BLOCK
# REASONING: Prevents resource exhaustion and cascading node failures

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    
    msg := sprintf(
        "BLOCKED: Container '%s' in deployment '%s' missing memory limit.\n\nWithout memory limits, container can consume all node memory and crash neighboring pods.\n\nAdd:\nresources:\n  limits:\n    memory: '512Mi'\n  requests:\n    memory: '256Mi'",
        [container.name, input.metadata.name]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    
    msg := sprintf(
        "BLOCKED: Container '%s' in deployment '%s' missing CPU limit.\n\nWithout CPU limits, container can starve other workloads on the node.\n\nAdd:\nresources:\n  limits:\n    cpu: '500m'\n  requests:\n    cpu: '250m'",
        [container.name, input.metadata.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
    
    msg := sprintf(
        "WARNING: Container '%s' missing memory request.\n\nScheduler cannot make informed placement decisions.\n\nRecommended: Set requests to 50-75%% of limits.",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    
    msg := sprintf(
        "WARNING: Container '%s' missing CPU request.\n\nScheduler cannot guarantee minimum CPU allocation.",
        [container.name]
    )
}