package kubernetes.pod_security.availability

# POLICY: Production deployments should have multiple replicas
# SEVERITY: WARN
# REASONING: Single replica means no redundancy during updates or failures

warn[msg] {
    input.kind == "Deployment"
    input.metadata.namespace == "production"
    input.spec.replicas < 2
    
    msg := sprintf(
        "Deployment '%s' has only %d replica in production.\n\nReliability risk: No redundancy during rolling updates or node failures.\n\nSet: replicas: 3",
        [input.metadata.name, input.spec.replicas]
    )
}

warn[msg] {
    input.kind == "Deployment"
    input.spec.replicas >= 2
    # Check if corresponding PDB exists (simplified check)
    not input.metadata.annotations["pdb.kubernetes.io/exists"]
    
    msg := sprintf(
        "Deployment '%s' with %d replicas missing PodDisruptionBudget.\n\nCluster maintenance could disrupt all replicas simultaneously.",
        [input.metadata.name, input.spec.replicas]
    )
}