#!/bin/bash
#===============================================================================
# SOLUTION: Question 2 - Fix Broken Ingress (404 Error)
#===============================================================================

# Step 1: Check current ingress configuration
kubectl describe ingress web-ingress -n production

# Step 2: Verify backend service exists and has endpoints
kubectl get svc web-service -n production
kubectl get endpoints web-service -n production

# Step 3: Edit ingress to fix issues
kubectl edit ingress web-ingress -n production

# Issues to fix:
# 1. Host: app.exmple.com -> app.example.com (typo fix)
# 2. Service name: web-svc -> web-service
# 3. Port: 8080 -> 80

# Alternative: Patch commands
kubectl patch ingress web-ingress -n production --type='json' \
  -p='[
    {"op": "replace", "path": "/spec/rules/0/host", "value": "app.example.com"},
    {"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/name", "value": "web-service"},
    {"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/service/port/number", "value": 80}
  ]'

# Verify the fix
kubectl describe ingress web-ingress -n production

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. Always check kubectl describe ingress first
# 2. Verify service exists: kubectl get svc -n <ns>
# 3. Check endpoints: kubectl get endpoints <svc> -n <ns>
# 4. Empty endpoints = selector mismatch between service and pods
# 5. Common ingress issues: typos in host/service name, wrong ports
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds)
================================================================================
Step 1: Identify the issues
  kubectl describe ingress web-ingress -n production
  kubectl get svc -n production

Step 2: Fix with kubectl edit (visual - catches typos easily)
  kubectl edit ingress web-ingress -n production
  - Look for typos in host (app.exmple.com -> app.example.com)
  - Check service name matches existing service
  - Verify port number matches service port
  Save and exit (:wq)

TIP: kubectl edit is faster than patch for troubleshooting because
you can see and fix ALL issues at once.
================================================================================
'
