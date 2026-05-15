package kubernetes.pod_security.probes

# POLICY: Containers should have liveness and readiness probes
# SEVERITY: WARN
# REASONING: Enables automatic recovery and prevents traffic to unhealthy pods

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    
    msg := sprintf(
        "Container '%s' missing liveness probe.\n\nKubernetes cannot detect and restart unresponsive containers.\n\nAdd:\nlivenessProbe:\n  httpGet:\n    path: /health\n    port: 8080\n  initialDelaySeconds: 30\n  periodSeconds: 10",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    
    msg := sprintf(
        "Container '%s' missing readiness probe.\n\nTraffic may route to pods before they're ready.\n\nAdd:\nreadinessProbe:\n  httpGet:\n    path: /ready\n    port: 8080\n  initialDelaySeconds: 5\n  periodSeconds: 5",
        [container.name]
    )
}