package kubernetes.availability

# SEVERITY: WARN
# REASONING: Only matters during cluster maintenance
# BLAST RADIUS: Low - affects availability during specific maintenance windows
# REVERSIBILITY: Easy - PDB can be added independently

warn[msg] {
    input.kind == "Deployment"
    input.spec.replicas >= 2
    input.metadata.annotations["pdb.required"] != "false"
    msg := sprintf(
        "Deployment '%s' missing PodDisruptionBudget.\n\nImpact: Cluster maintenance could disrupt all replicas simultaneously.",
        [input.metadata.name]
    )
}