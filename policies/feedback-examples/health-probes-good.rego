package kubernetes.healthprobes

# GOOD: Explains which probe, shows example configuration
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf(
        "Container '%s' missing liveness probe.\n\nAdd to container spec:\nlivenessProbe:\n  httpGet:\n    path: /health\n    port: 8080\n  initialDelaySeconds: 30\n  periodSeconds: 10\n\nAlternatively use: tcpSocket or exec probes",
        [container.name]
    )
}