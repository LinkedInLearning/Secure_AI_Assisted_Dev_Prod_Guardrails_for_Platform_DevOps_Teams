package kubernetes.healthprobes

# BAD: Doesn't tell you which probe or how to fix
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := "Health probe missing"
}