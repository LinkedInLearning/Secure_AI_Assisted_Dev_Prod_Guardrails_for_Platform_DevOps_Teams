# Stack Dependencies and Approval Chains

Complex infrastructure changes often span multiple Terraform stacks or modules. Stack dependencies ensure changes deploy in the correct order with appropriate approvals at each stage.

## Example: New Microservice Deployment

Adding a new microservice requires coordinated infrastructure changes:

```
Network Stack → Compute Stack → IAM Stack → Application Deployment
↓               ↓              ↓                ↓
Network Team   Platform Team  Security Team   DevOps Team
```

### Step 1: Network Stack
**Changes:**
- New subnet in existing VNet
- Network Security Group
- Application Gateway backend pool entry

**Approvers:** Network Team Lead
**Risk Tier:** High

### Step 2: Compute Stack (depends on Network Stack)
**Changes:**
- Azure Container Instances or App Service
- Auto-scaling rules
- Health probes

**Approvers:** Platform Engineering Manager
**Risk Tier:** Standard

**Dependency:** Cannot deploy until Network Stack approved and deployed

### Step 3: IAM Stack (depends on Compute Stack)
**Changes:**
- Managed identity for the service
- Role assignments (Key Vault access, Storage access)
- Principle of least privilege enforcement

**Approvers:** Security Team Lead
**Risk Tier:** Critical

**Dependency:** Cannot deploy until Compute Stack exists (needs resource IDs)

### Step 4: Application Deployment
**Changes:**
- Container image deployment
- Environment variables
- Scaling configuration

**Approvers:** DevOps Team
**Risk Tier:** Standard

**Dependency:** All infrastructure must exist

## Implementation Pattern

### Option 1: Spacelift/env0 Stack Dependencies

```hcl
# stack-network.tf
stack "network" {
  workspace_id = "teriana-network"
  
  approval {
    required_reviewers = ["network-leads"]
  }
}

# stack-compute.tf
stack "compute" {
  workspace_id = "teriana-compute"
  
  depends_on = [stack.network]
  
  approval {
    required_reviewers = ["platform-managers"]
  }
  
  inputs = {
    subnet_id = stack.network.outputs.subnet_id
    nsg_id    = stack.network.outputs.nsg_id
  }
}

# stack-iam.tf
stack "iam" {
  workspace_id = "teriana-iam"
  
  depends_on = [stack.compute]
  
  approval {
    required_reviewers = ["security-leads"]
  }
  
  inputs = {
    service_principal_id = stack.compute.outputs.identity_id
  }
}
```

### Option 2: GitHub Actions with Manual Gates

```yaml
name: Deploy New Service Infrastructure

on:
  workflow_dispatch:
    inputs:
      service_name:
        description: 'Service name'
        required: true

jobs:
  deploy-network:
    runs-on: ubuntu-latest
    environment: 
      name: production-network
    outputs:
      subnet_id: ${{ steps.deploy.outputs.subnet_id }}
      nsg_id: ${{ steps.deploy.outputs.nsg_id }}
    steps:
      - name: Deploy Network Stack
        id: deploy
        run: |
          cd infrastructure/network
          terraform apply -auto-approve
          echo "subnet_id=$(terraform output -raw subnet_id)" >> $GITHUB_OUTPUT
          echo "nsg_id=$(terraform output -raw nsg_id)" >> $GITHUB_OUTPUT

  deploy-compute:
    needs: deploy-network
    runs-on: ubuntu-latest
    environment:
      name: production-compute
    outputs:
      identity_id: ${{ steps.deploy.outputs.identity_id }}
    steps:
      - name: Deploy Compute Stack
        id: deploy
        env:
          SUBNET_ID: ${{ needs.deploy-network.outputs.subnet_id }}
          NSG_ID: ${{ needs.deploy-network.outputs.nsg_id }}
        run: |
          cd infrastructure/compute
          terraform apply -auto-approve \
            -var="subnet_id=$SUBNET_ID" \
            -var="nsg_id=$NSG_ID"
          echo "identity_id=$(terraform output -raw identity_id)" >> $GITHUB_OUTPUT

  deploy-iam:
    needs: deploy-compute
    runs-on: ubuntu-latest
    environment:
      name: production-iam
    steps:
      - name: Deploy IAM Stack
        env:
          IDENTITY_ID: ${{ needs.deploy-compute.outputs.identity_id }}
        run: |
          cd infrastructure/iam
          terraform apply -auto-approve \
            -var="service_identity_id=$IDENTITY_ID"
```

Each `environment` in the workflow maps to a GitHub Environment with its own protection rules and required approvers.

## Cross-Stack Approval Coordination

When changes span multiple stacks, all required approvals must be collected before deployment begins:

**Approval Coordination Pattern:**
1. Engineer opens PR affecting network + compute + IAM
2. GitHub Actions analyzes changes, identifies affected stacks
3. Approval requests sent to all required teams
4. Deployment blocked until ALL teams approve
5. Stacks deploy in dependency order

## Benefits of Stack Dependencies

1. **Correct Deployment Order**: Infrastructure dependencies respected automatically
2. **Team Boundaries**: Each team approves their domain
3. **Rollback Capability**: Can roll back individual stacks if later stages fail
4. **Audit Trail**: Clear record of who approved what at each stage
5. **Blast Radius Containment**: Failure in one stack doesn't require redeployment of all stacks