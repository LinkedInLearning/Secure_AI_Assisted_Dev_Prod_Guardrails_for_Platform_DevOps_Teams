package kubernetes.reliability.security

# POLICY: Containers must not run as root or privileged
# SEVERITY: BLOCK
# REASONING: Prevents privilege escalation and container escape

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    
    msg := sprintf(
        "BLOCKED: Container '%s' runs in privileged mode.\n\nSecurity risk: Can access host resources and escape container isolation.\n\nRemove: privileged: true",
        [container.name]
    )
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    
    # Check if runAsUser is explicitly set to 0
    container.securityContext.runAsUser == 0
    
    msg := sprintf(
        "BLOCKED: Container '%s' explicitly runs as root (UID 0).\n\nSecurity risk: Root access inside container enables privilege escalation.\n\nSet: runAsUser: 1000 (or any non-zero UID)",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    
    # No security context at all
    not container.securityContext
    
    msg := sprintf(
        "WARNING: Container '%s' missing security context.\n\nBest practice: Explicitly set security constraints.\n\nAdd:\nsecurityContext:\n  runAsNonRoot: true\n  runAsUser: 1000\n  allowPrivilegeEscalation: false\n  readOnlyRootFilesystem: true\n  capabilities:\n    drop:\n    - ALL",
        [container.name]
    )
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    
    # Has security context but doesn't explicitly set runAsNonRoot
    container.securityContext
    not container.securityContext.runAsNonRoot == true
    
    msg := sprintf(
        "WARNING: Container '%s' doesn't explicitly enforce runAsNonRoot.\n\nBest practice: Set runAsNonRoot: true to prevent root execution.",
        [container.name]
    )
}