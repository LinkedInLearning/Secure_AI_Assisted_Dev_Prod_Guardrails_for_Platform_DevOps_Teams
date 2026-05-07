package kubernetes.metadata

# Should this BLOCK or WARN?
deny[msg] {
    input.kind == "Deployment"
    not input.metadata.labels.team
    msg := "Deployment missing 'team' label.\n\nAdd:\nmetadata:\n  labels:\n    team: 'platform'"
}

deny[msg] {
    input.kind == "Deployment"
    not input.metadata.labels.component
    msg := "Deployment missing 'component' label.\n\nAdd:\nmetadata:\n  labels:\n    component: 'api'"
}