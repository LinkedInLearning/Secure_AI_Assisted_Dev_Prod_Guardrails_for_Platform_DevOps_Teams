package kubernetes.resources

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "Container '%s' missing memory limit.\n\nAdd:\nresources:\n  limits:\n    memory: '512Mi'",
        [container.name]
    )
}