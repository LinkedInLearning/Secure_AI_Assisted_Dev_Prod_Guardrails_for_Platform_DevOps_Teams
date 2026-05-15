package kubernetes.pod_security.security

# POLICY: Containers must not run privileged
# SEVERITY: BLOCK
# REASONING: Privileged containers can escape to host

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    
    msg := sprintf(
        "Container '%s' runs in privileged mode.\n\nSecurity risk: Can access host resources and escape container.\n\nRemove: privileged: true",
        [container.name]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.runAsUser == 0
    
    msg := sprintf(
        "Container '%s' runs as root (UID 0).\n\nSecurity risk: Root access inside container.\n\nSet: runAsUser: 1000 (or any non-zero UID)",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.securityContext.allowPrivilegeEscalation == false
    
    msg := sprintf(
        "Container '%s' missing allowPrivilegeEscalation: false.\n\nBest practice: Explicitly disable privilege escalation.",
        [container.name]
    )
}