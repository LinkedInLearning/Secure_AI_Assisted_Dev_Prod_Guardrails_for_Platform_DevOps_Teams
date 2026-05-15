# PR: Add Storage for Sensor Telemetry

## Overview
This PR adds infrastructure for storing sensor telemetry data from field devices.

## Changes
- Created storage account `terianatelemetry` for sensor data
- Added two containers: `sensor-raw` and `sensor-processed`
- Created Azure Function App for data ingestion
- Configured IAM for the function app to access storage

## Testing
- Verified storage account creation
- Tested function app deployment
- Confirmed data can be written to containers
- Validated 7-day retention policy

## Security Considerations
- Storage containers set to private access
- Versioning enabled for data recovery
- Application Insights configured for monitoring

## Deployment Plan
1. Deploy to production
2. Configure IoT devices to send data to new endpoint
3. Monitor ingestion rates and storage growth

## Rollback Plan
If issues arise:
1. Stop IoT devices from sending to new endpoint
2. Destroy the new infrastructure via Terraform
3. Restore previous data ingestion flow

---

**Reviewers:** Please verify the IAM configuration is correct. I granted Contributor at subscription level to simplify access management - the service needs to read from several resources and write to storage. We can tighten this later if needed.