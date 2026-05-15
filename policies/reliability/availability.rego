package kubernetes.reliability.availability

# POLICY: Production deployments should have multiple replicas
# SEVERITY: WARN
# REASONING: Single replica means no redundancy during updates or failures

warn[msg] {
    input.kind == "Deployment"
    input.metadata.namespace == "production"
    input.spec.replicas < 2
    
    msg := sprintf(
        "WARNING: Deployment '%s' has only %d replica in production namespace.\n\nReliability risk: No redundancy during rolling updates, node failures, or maintenance.\n\nRecommended: Set replicas: 3 for production services.\n\nSingle replica means:\n- Zero downtime during rolling updates impossible\n- Service outage during node drain/failure\n- No capacity during pod restarts",
        [input.metadata.name, input.spec.replicas]
    )
}

warn[msg] {
    input.kind == "Deployment"
    input.spec.replicas >= 2
    
    # Check for absence of anti-affinity (simplified check)
    not input.spec.template.spec.affinity.podAntiAffinity
    
    msg := sprintf(
        "WARNING: Deployment '%s' with %d replicas has no pod anti-affinity.\n\nReliability risk: All replicas could be scheduled on the same node.\n\nRecommended: Add pod anti-affinity to spread replicas across nodes.",
        [input.metadata.name, input.spec.replicas]
    )
}