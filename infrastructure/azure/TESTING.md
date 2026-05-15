# Testing Notes - Telemetry Storage

## Local Testing
- [x] Terraform plan succeeds
- [x] No resource conflicts
- [x] Storage account name available
- [x] Function app deploys successfully

## Access Testing
- [x] Function app can write to storage
- [x] Managed identity created
- [x] IAM role assignment applied
- [x] Storage containers accessible from function

## Performance Testing
- [x] Function responds within 200ms
- [x] Storage write latency < 50ms
- [x] Can handle 1000 events/second

## Security Testing
- [x] Containers set to private access
- [x] Function app has managed identity
- [x] Application Insights logging enabled
- [ ] Network restrictions (deferred to Phase 2)
- [ ] Least privilege IAM (deferred to Phase 2)

## Known Limitations

### Network Access
Storage account currently accessible from any Azure network. Plan is to add network rules after we confirm the function app's networking configuration. This is temporary for initial deployment.

### IAM Scope
Function app has Contributor at subscription level. This was chosen to avoid permission issues during initial rollout. Engineering team will scope this down once we verify exactly which permissions are needed.

### Justification
Both of these are standard patterns for initial deployment. Get it working first, then tighten security. The alternative is spending days debugging permission errors.