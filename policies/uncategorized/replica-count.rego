package kubernetes.availability

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    input.spec.replicas < 2
    msg := sprintf(
        "Deployment '%s' has %d replica(s).\n\nReliability risk: No redundancy during rolling updates or node failures.\n\nRecommended: 2+ replicas for production.",
        [input.metadata.name, input.spec.replicas]
    )
}