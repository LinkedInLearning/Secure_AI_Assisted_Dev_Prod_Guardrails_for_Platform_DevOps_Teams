package kubernetes.metadata

# SEVERITY: WARN
# REASONING: Reduces observability, doesn't affect functionality
# BLAST RADIUS: Low - only impacts monitoring and organization
# REVERSIBILITY: Easy - labels can be added anytime

warn[msg] {
    input.kind == "Deployment"
    not input.metadata.labels.team
    msg := "Deployment missing 'team' label.\n\nAdd:\nmetadata:\n  labels:\n    team: 'platform'"
}

warn[msg] {
    input.kind == "Deployment"
    not input.metadata.labels.component
    msg := "Deployment missing 'component' label.\n\nAdd:\nmetadata:\n  labels:\n    component: 'api'"
}