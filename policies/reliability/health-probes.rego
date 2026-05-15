package kubernetes.reliability.probes

# POLICY: Production containers should have health probes
# SEVERITY: WARN
# REASONING: Enables automatic recovery and prevents traffic to unhealthy pods

warn[msg] {
    input.kind == "Deployment"
    input.metadata.namespace == "production"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    
    msg := sprintf(
        "WARNING: Container '%s' in production missing liveness probe.\n\nKubernetes cannot detect and restart unresponsive containers.\n\nAdd:\nlivenessProbe:\n  httpGet:\n    path: /health\n    port: 8080\n  initialDelaySeconds: 30\n  periodSeconds: 10\n  timeoutSeconds: 5\n  failureThreshold: 3",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    input.metadata.namespace == "production"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    
    msg := sprintf(
        "WARNING: Container '%s' in production missing readiness probe.\n\nTraffic may route to pods before they're ready, causing user-facing errors.\n\nAdd:\nreadinessProbe:\n  httpGet:\n    path: /ready\n    port: 8080\n  initialDelaySeconds: 5\n  periodSeconds: 5\n  timeoutSeconds: 3\n  failureThreshold: 2",
        [container.name]
    )
}