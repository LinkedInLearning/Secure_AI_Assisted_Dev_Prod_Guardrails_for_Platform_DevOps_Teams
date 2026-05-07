package kubernetes.resources

# SEVERITY: WARN
# REASONING: Affects scheduling efficiency, not immediate reliability
# BLAST RADIUS: Low - suboptimal placement, not failure
# REVERSIBILITY: Easy - can be added via rolling update

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf(
        "Container '%s' missing CPU request.\n\nImpact: Scheduler cannot make informed placement decisions.",
        [container.name]
    )
}