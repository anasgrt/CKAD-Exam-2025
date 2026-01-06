#!/bin/bash
#===============================================================================
# SOLUTION: Question 8 - Canary Deployment (Professional-Sea4743 Pattern)
# Pattern: 10 pod limit, 5 stable replicas, 20% traffic to canary
#===============================================================================

# Step 1: Scale down stable deployment from 5 to 4 replicas
echo "Step 1: Scale down stable deployment from 5 to 4 replicas"
kubectl scale deployment web-app -n canary-ns --replicas=4

# Step 2: Create the canary deployment with 1 replica
echo "Step 2: Create canary deployment with 1 replica"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-canary
  namespace: canary-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
      version: canary
  template:
    metadata:
      labels:
        app: web-app
        version: canary
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
EOF

# Verify deployments
kubectl get deployments -n canary-ns

# Verify pods with labels
kubectl get pods -n canary-ns -l app=web-app --show-labels

# Verify service endpoints (should show 5 endpoints)
kubectl get endpoints web-service -n canary-ns

#===============================================================================
# KEY POINTS (Professional-Sea4743 Pattern):
#===============================================================================
# 1. CONSTRAINT: 10 pod limit total in namespace
# 2. Started with 5 stable replicas
# 3. Need 20% traffic to canary = 1/5 ratio = 1 canary pod
# 4. Scale down stable: 5 -> 4 replicas
# 5. Create canary: 1 replica
# 6. Total: 4 + 1 = 5 pods (within 10 pod limit)
# 7. Traffic split: 4/5 = 80% stable, 1/5 = 20% canary
# 8. Both deployments must have app=web-app label for service selector
# 9. Use 'version' label to distinguish: stable vs canary
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: Scale stable deployment from 5 to 4 (10 sec)
  kubectl scale deployment web-app -n canary-ns --replicas=4

Step 2: Create canary from existing deployment (60 sec)
  kubectl get deployment web-app -n canary-ns -o yaml > canary.yaml
  # Edit canary.yaml:
  - Change name: web-app-canary
  - Change replicas: 1
  - Change image to new version (nginx:1.20)
  - KEEP app=web-app label! Add version: canary
  kubectl apply -f canary.yaml

Step 3: Verify (20 sec)
  kubectl get pods -n canary-ns -l app=web-app --show-labels

CRITICAL: Both deployments MUST have same "app" label for Service routing!
Traffic split = pod ratio (4 stable + 1 canary = 20% canary)
================================================================================
'
#===============================================================================
