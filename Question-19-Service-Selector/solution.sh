#!/bin/bash
#===============================================================================
# SOLUTION: Question 19 - Service Selector Fix
#===============================================================================

# Step 1: Check current service selector
kubectl get svc frontend-svc -n svc-ns -o yaml

# Step 2: Check pod labels
kubectl get pods -n svc-ns --show-labels

# Step 3: Check endpoints (should be empty)
kubectl get endpoints frontend-svc -n svc-ns

# Step 4: Fix the service selector

#-------------------------------------------------------------------------------
# METHOD A: Using kubectl edit (RECOMMENDED for exam - visual editing)
#-------------------------------------------------------------------------------
# kubectl edit svc frontend-svc -n svc-ns
#
# Find the selector section and fix:
#
#   spec:
#     selector:
#       app: frontend      # CHANGE FROM: frontend-wrong
#       tier: web
#
# Save and exit (:wq in vim)
#-------------------------------------------------------------------------------

# Option A: Edit directly
kubectl edit svc frontend-svc -n svc-ns
# Change: app: frontend-wrong → app: frontend

#-------------------------------------------------------------------------------
# METHOD B: Using kubectl patch (alternative - single command)
#-------------------------------------------------------------------------------
# Option B: Patch the service
kubectl patch svc frontend-svc -n svc-ns \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/selector/app", "value": "frontend"}]'

# Option C: Delete and recreate
kubectl delete svc frontend-svc -n svc-ns
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: svc-ns
spec:
  selector:
    app: frontend
    tier: web
  ports:
  - port: 80
    targetPort: 80
EOF

# Step 5: Verify endpoints now exist
kubectl get endpoints frontend-svc -n svc-ns
kubectl get svc frontend-svc -n svc-ns -o wide

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. Service selector MUST match Pod labels exactly
# 2. Kubernetes creates Endpoints automatically when selector matches
# 3. No endpoints usually means selector mismatch or no running pods
# 4. Use --show-labels to quickly see pod labels
# 5. Service port can differ from targetPort
# 6. All selector labels must match (AND logic)
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 45 seconds)
================================================================================
Step 1: Compare service selector vs pod labels (15 sec)
  kubectl get svc frontend-svc -n svc-ns -o jsonpath="{.spec.selector}"
  kubectl get pods -n svc-ns --show-labels
  # Find the mismatch!

Step 2: Fix selector with kubectl edit (20 sec)
  kubectl edit svc frontend-svc -n svc-ns
  # Change: app: frontend-wrong -> app: frontend
  Save (:wq)

Step 3: Verify endpoints exist (10 sec)
  kubectl get endpoints frontend-svc -n svc-ns
  # Should now show pod IPs!

TIP: No endpoints = selector mismatch or no running pods
     Use --show-labels to see actual pod labels quickly
================================================================================
'
