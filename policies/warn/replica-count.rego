package kubernetes.availability

# SEVERITY: WARN
# REASONING: Creates risk during updates but not immediate failure
# BLAST RADIUS: Medium - affects availability during deployments
# REVERSIBILITY: Easy - replica count can be increased anytime

warn[msg] {
    input.kind == "Deployment"
    input.spec.replicas < 2
    msg := sprintf(
        "Deployment '%s' has %d replica(s).\n\nReliability risk: No redundancy during rolling updates or node failures.\n\nRecommended: 2+ replicas for production.",
        [input.metadata.name, input.spec.replicas]
    )
}