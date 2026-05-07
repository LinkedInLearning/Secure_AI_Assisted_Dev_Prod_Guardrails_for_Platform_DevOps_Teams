package kubernetes.probes

# SEVERITY: WARN
# REASONING: May cause brief traffic errors during deployments
# BLAST RADIUS: Low - affects only during rolling updates
# REVERSIBILITY: Easy - can be added via rolling update

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf(
        "Container '%s' missing readiness probe.\n\nImpact: Traffic may route to pods before they're ready to serve requests.",
        [container.name]
    )
}