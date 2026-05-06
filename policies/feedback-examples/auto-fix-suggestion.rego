package kubernetes.images

# GOOD: Shows exact line to change
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "Container '%s' uses ':latest' tag.\n\nCurrent: image: %s\nChange to: image: %s:v1.2.3\n\nPin to specific version for reproducible deployments.",
        [container.name, container.image, split(container.image, ":")[0]]
    )
}