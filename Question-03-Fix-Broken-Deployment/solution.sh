#!/bin/bash
#===============================================================================
# SOLUTION: Question 3 - Fix Broken Deployment (Incorrect Secret)
#===============================================================================

# Step 1: Check pod status and errors
kubectl get pods -n staging
kubectl describe pod -l app=backend -n staging | grep -A5 "Events:"

# Step 2: Verify available secrets
kubectl get secrets -n staging

# Step 3: Edit deployment to fix secret reference
kubectl edit deployment backend-deployment -n staging
# Change: secretRef.name: db-credentials-old -> db-credentials

# Alternative: Use patch command
kubectl patch deployment backend-deployment -n staging --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/envFrom/0/secretRef/name", "value": "db-credentials"}]'

# Step 4: Verify the fix
kubectl rollout status deployment/backend-deployment -n staging
kubectl get pods -n staging

# Step 5: Verify env vars are loaded
POD_NAME=$(kubectl get pods -n staging -l app=backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD_NAME" -n staging -- env | grep DB

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. Check pod events for "secret not found" errors
# 2. kubectl describe pod shows mount/env errors
# 3. envFrom.secretRef.name must match an existing secret
# 4. After fix, old pods will be terminated and new ones created
# 5. Use kubectl rollout status to wait for deployment
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 45 seconds)
================================================================================
Step 1: Find the issue (10 sec)
  kubectl describe pod -l app=backend -n staging | grep -i secret
  kubectl get secrets -n staging

Step 2: Fix with kubectl edit (20 sec)
  kubectl edit deployment backend-deployment -n staging
  - Find: secretRef.name: db-credentials-old
  - Change to: secretRef.name: db-credentials
  Save and exit (:wq)

Step 3: Verify (15 sec)
  kubectl rollout status deployment/backend-deployment -n staging

TIP: The error message tells you which secret is missing!
================================================================================
'
