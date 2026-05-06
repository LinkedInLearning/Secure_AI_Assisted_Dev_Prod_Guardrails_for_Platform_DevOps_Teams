package kubernetes.resourcelimits

# GOOD: Specific, actionable error message with fix
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "Container '%s' missing memory limit.\n\nAdd to manifest:\nresources:\n  limits:\n    memory: '512Mi'\n\nRecommended values: 256Mi (small), 512Mi (medium), 1Gi (large)",
        [container.name]
    )
}