package kubernetes.images

# SEVERITY: WARN
# REASONING: Creates unpredictability but not immediate failure
# BLAST RADIUS: Low - affects reproducibility, not functionality
# REVERSIBILITY: Easy - tag can be pinned anytime

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "Container '%s' uses ':latest' tag.\n\nPin to specific version: %s:v1.2.3",
        [container.name, split(container.image, ":")[0]]
    )
}