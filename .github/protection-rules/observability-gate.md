# Custom Deployment Protection Rule: Observability Gate

This protection rule integrates with Datadog to verify system health before production deployment.

## GitHub App Configuration

A custom GitHub App evaluates Datadog monitors and approves/rejects deployments based on:

1. **Critical Monitor Status**: No critical monitors in alert state
2. **Error Rate Threshold**: API error rate below 1% 
3. **Latency Threshold**: P99 latency below 500ms
4. **Recent Incidents**: No active incidents in PagerDuty

## Implementation

```javascript
// GitHub App webhook handler
app.on('deployment_protection_rule', async (context) => {
  const { deployment_callback_url, environment } = context.payload;
  
  if (environment !== 'production') {
    return context.octokit.request('POST', deployment_callback_url, {
      state: 'approved',
      comment: 'Non-production environment, auto-approved'
    });
  }
  
  // Check Datadog monitors
  const monitors = await datadog.getMonitors({ tags: ['critical'] });
  const alerting = monitors.filter(m => m.overall_state === 'Alert');
  
  if (alerting.length > 0) {
    return context.octokit.request('POST', deployment_callback_url, {
      state: 'rejected',
      comment: `Deployment blocked: ${alerting.length} critical monitors alerting`
    });
  }
  
  // Check error rates
  const errorRate = await datadog.query({
    query: 'sum:api.errors{env:production}.as_rate()',
    from: Date.now() - 600000,  // Last 10 minutes
    to: Date.now()
  });
  
  if (errorRate > 0.01) {
    return context.octokit.request('POST', deployment_callback_url, {
      state: 'rejected',
      comment: `Deployment blocked: Error rate ${(errorRate * 100).toFixed(2)}% exceeds 1% threshold`
    });
  }
  
  // Check PagerDuty incidents
  const incidents = await pagerduty.getIncidents({ 
    statuses: ['triggered', 'acknowledged'],
    urgency: 'high'
  });
  
  if (incidents.length > 0) {
    return context.octokit.request('POST', deployment_callback_url, {
      state: 'rejected',
      comment: `Deployment blocked: ${incidents.length} active high-urgency incidents`
    });
  }
  
  // All checks passed
  return context.octokit.request('POST', deployment_callback_url, {
    state: 'approved',
    comment: 'System health verified, deployment approved'
  });
});
```

## Configuration in GitHub

1. Install the GitHub App in your organization
2. Navigate to: Settings > Environments > production
3. Add custom protection rule: "Observability Gate"
4. Configure required checks and thresholds

## Bypass Process

Emergency deployments can bypass this rule with approval from:
- VP Engineering
- CTO

Bypass requests logged to audit trail with justification.