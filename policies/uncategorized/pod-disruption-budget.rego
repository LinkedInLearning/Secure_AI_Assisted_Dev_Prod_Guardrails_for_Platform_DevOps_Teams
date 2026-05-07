package kubernetes.availability

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    input.spec.replicas >= 2
    # Simplified check - in reality would check for matching PDB resource
    input.metadata.annotations["pdb.required"] != "false"
    msg := sprintf(
        "Deployment '%s' missing PodDisruptionBudget.\n\nImpact: Cluster maintenance could disrupt all replicas simultaneously.",
        [input.metadata.name]
    )
}