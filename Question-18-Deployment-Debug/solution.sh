#!/bin/bash
#===============================================================================
# SOLUTION: Question 18 - Fix Deployment - Container Name & Image + Resume Rollout
#===============================================================================

# Step 1: Check deployment status (it's paused)
echo "📋 Step 1: Check current deployment"
kubectl get deployment api-server -n api-ns
echo ""
echo "Note: Deployment is PAUSED - see spec.paused=true"

# Step 2: Check current container configuration
echo ""
echo "📋 Step 2: Check current container config"
kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.template.spec.containers[0].name}'
echo " (current container name - WRONG)"
kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.template.spec.containers[0].image}'
echo " (current image - WRONG)"

# Step 3: Fix the deployment
echo ""
echo "📋 Step 3: Fix container name and image"

#-------------------------------------------------------------------------------
# METHOD A: Using kubectl edit (RECOMMENDED for exam - visual editing)
#-------------------------------------------------------------------------------
# kubectl edit deployment api-server -n api-ns
#
# Find the containers section and fix:
#
#   spec:
#     template:
#       spec:
#         containers:
#         - name: api-container     # CHANGE FROM: wrong-name
#           image: nginx:1.21       # CHANGE FROM: nginx:wrong
#           ports:
#           - containerPort: 80
#
# Save and exit (:wq in vim)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# METHOD B: Using kubectl patch (alternative - single command)
#-------------------------------------------------------------------------------
# Fix container name and image
kubectl patch deployment api-server -n api-ns --type='json' -p='[
  {"op": "replace", "path": "/spec/template/spec/containers/0/name", "value": "api-container"},
  {"op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "nginx:1.21"}
]'

# Alternative: Use kubectl edit
# kubectl edit deployment api-server -n api-ns
# Change:
#   name: wrong-name -> name: api-container
#   image: nginx:wrong -> image: nginx:1.21

# Step 4: Resume the paused deployment
echo ""
echo "📋 Step 4: Resume the paused deployment"
kubectl rollout resume deployment/api-server -n api-ns

# Step 5: Wait for rollout to complete
echo ""
echo "📋 Step 5: Wait for rollout"
kubectl rollout status deployment/api-server -n api-ns --timeout=120s

# Step 6: Verify the fix
echo ""
echo "📋 Step 6: Verify the fix"
kubectl get deployment api-server -n api-ns
kubectl get pods -n api-ns -l app=api-server

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. NEVER delete and recreate - always edit in-place (preserves history)
# 2. Deployment may be paused - must resume after editing
# 3. kubectl patch --type='json' for precise edits
# 4. kubectl edit opens the resource in editor (vi/vim)
# 5. kubectl rollout resume to unpause
# 6. kubectl rollout status to wait for completion
# 7. Container name is at spec.template.spec.containers[].name
# 8. Image is at spec.template.spec.containers[].image
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds)
================================================================================
Step 1: Edit deployment to fix issues (40 sec)
  kubectl edit deployment api-server -n api-ns
  # Fix container name: wrong-name -> api-container
  # Fix image: nginx:wrong -> nginx:1.21
  Save (:wq)

Step 2: Resume if paused (10 sec)
  kubectl rollout resume deployment/api-server -n api-ns

Step 3: Verify (10 sec)
  kubectl rollout status deployment/api-server -n api-ns

TIP: kubectl edit is FASTEST for this - you can fix BOTH issues
     in a single edit session!
REMEMBER: Always check if deployment is paused (spec.paused: true)
================================================================================
'
