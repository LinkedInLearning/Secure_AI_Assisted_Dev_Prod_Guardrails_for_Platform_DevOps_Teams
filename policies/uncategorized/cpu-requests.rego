package kubernetes.resources

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf(
        "Container '%s' missing CPU request.\n\nImpact: Scheduler cannot make informed placement decisions.",
        [container.name]
    )
}