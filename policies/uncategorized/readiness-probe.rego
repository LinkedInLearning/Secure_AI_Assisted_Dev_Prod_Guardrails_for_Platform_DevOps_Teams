package kubernetes.probes

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf(
        "Container '%s' missing readiness probe.\n\nImpact: Traffic may route to pods before they're ready to serve requests.",
        [container.name]
    )
}