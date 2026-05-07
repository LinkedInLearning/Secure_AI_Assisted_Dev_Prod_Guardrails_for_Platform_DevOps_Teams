package kubernetes.probes

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf(
        "Container '%s' missing liveness probe.\n\nKubernetes cannot detect when container becomes unresponsive.",
        [container.name]
    )
}