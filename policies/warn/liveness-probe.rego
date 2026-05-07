package kubernetes.probes

# SEVERITY: WARN
# REASONING: Degrades reliability but doesn't cause immediate failure
# BLAST RADIUS: Medium - affects only this service
# REVERSIBILITY: Easy - can be added via rolling update

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf(
        "Container '%s' missing liveness probe.\n\nKubernetes cannot detect when container becomes unresponsive.",
        [container.name]
    )
}