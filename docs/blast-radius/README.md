# Blast Radius Examples

This directory contains scenarios showing how unsafe defaults amplify failures.

## Scenarios

1. **Memory Exhaustion** - Pod without limits crashes node
2. **Circuit Breaker** - Service without timeouts exhausts threads
3. **Health Probes** - Dead pods multiply error rate
4. **Connection Pools** - Unbounded connections overwhelm dependencies

## Running the Examples

Each scenario has `before.yaml` (unsafe) and `after.yaml` (safe) configurations.

To see the difference:
```bash
# Deploy unsafe configuration
kubectl apply -f examples/cascading-failures/scenario-1-memory-exhaustion/before.yaml

# Trigger failure (e.g., deploy buggy version)
# Observe blast radius

# Deploy safe configuration  
kubectl apply -f examples/cascading-failures/scenario-1-memory-exhaustion/after.yaml

# Trigger same failure
# Observe contained failure
```

The scenarios demonstrate how safety defaults turn cascading failures into isolated incidents.