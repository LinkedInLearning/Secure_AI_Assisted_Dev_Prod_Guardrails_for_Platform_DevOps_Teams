# Teriana Harvest Production Infrastructure

This directory contains Terraform configurations for production Azure infrastructure.

## Recent Changes

### Sensor Telemetry Storage (Current)
Added dedicated storage for sensor telemetry data from field devices. The telemetry ingestion service receives data from IoT devices and stores it for analysis.

**Components:**
- Storage account: `terianatelemetry`
- Function app: `func-telemetry-prod`
- Service plan: `asp-telemetry-prod`

**Access Pattern:**
The function app uses a managed identity with Contributor role to write data to storage and read configuration from other Azure resources.

## Architecture
IoT Devices → Function App → Storage Account
↓
App Insights (monitoring)

## Known Issues
- [ ] Storage account network rules not yet configured (will add after validating connectivity)
- [ ] IAM role is broad (Contributor at subscription level) - will scope down after confirming required permissions
- [ ] Need to add backup configuration for storage account

## Deployment

```bash
terraform init
terraform plan
terraform apply
```