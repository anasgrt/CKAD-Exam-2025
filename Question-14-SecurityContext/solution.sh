#!/bin/bash
#===============================================================================
# SOLUTION: Question 14 - SecurityContext - Edit Existing Deployment
#===============================================================================

# Step 1: Check current deployment status (it's paused)
echo "📋 Step 1: Check current deployment"
kubectl get deployment secure-app -n secure-ns
echo ""
echo "Note: Deployment is PAUSED - see spec.paused=true"

# Step 2: Verify deployment is paused
echo ""
echo "📋 Step 2: Verify deployment is paused"
kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.paused}'
echo " (true = paused)"

# Step 3: Edit deployment to add securityContext
# You can use kubectl edit OR kubectl patch
echo ""
echo "📋 Step 3: Add securityContext"

#-------------------------------------------------------------------------------
# METHOD A: Using kubectl edit (RECOMMENDED for exam - visual editing)
#-------------------------------------------------------------------------------
# kubectl edit deployment secure-app -n secure-ns
#
# Find the spec.template.spec section and add pod-level securityContext:
#
#   spec:
#     template:
#       spec:
#         securityContext:           # ADD THIS SECTION (pod-level)
#           runAsUser: 10000
#         containers:
#         - name: app
#           image: nginx
#           securityContext:         # ADD THIS SECTION (container-level)
#             allowPrivilegeEscalation: false
#             capabilities:
#               add:
#               - NET_BIND_SERVICE
#
# Save and exit (:wq in vim)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# METHOD B: Using kubectl patch (alternative - single command)
#-------------------------------------------------------------------------------
# Using patch to add both pod-level and container-level securityContext (Professional-Sea4743: runAsUser 10000)
kubectl patch deployment secure-app -n secure-ns --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/securityContext",
    "value": {
      "runAsUser": 10000
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/securityContext",
    "value": {
      "allowPrivilegeEscalation": false,
      "capabilities": {
        "drop": ["ALL"],
        "add": ["NET_BIND_SERVICE"]
      }
    }
  }
]'

# Alternative: Use kubectl edit
# kubectl edit deployment secure-app -n secure-ns
# Add under spec.template.spec:
#   securityContext:
#     runAsUser: 1000
#     runAsGroup: 3000
#     fsGroup: 2000
# Add under spec.template.spec.containers[0]:
#   securityContext:
#     allowPrivilegeEscalation: false
#     capabilities:
#       drop: ["ALL"]
#       add: ["NET_BIND_SERVICE"]

# Step 4: Resume the paused deployment
echo ""
echo "📋 Step 4: Resume the paused deployment"
kubectl rollout resume deployment/secure-app -n secure-ns

# Step 5: Wait for rollout to complete
echo ""
echo "📋 Step 5: Wait for rollout"
kubectl rollout status deployment/secure-app -n secure-ns --timeout=120s

# Step 6: Verify security context was applied
echo ""
echo "📋 Step 6: Verify securityContext"
echo "Pod-level securityContext:"
kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.securityContext}' | jq .
echo ""
echo "Container-level securityContext:"
kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.containers[0].securityContext}' | jq .

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. NEVER delete and recreate - always edit in-place
# 2. Deployment may be paused - must resume after editing
# 3. Pod-level securityContext: runAsUser, runAsGroup, fsGroup
# 4. Container-level securityContext: allowPrivilegeEscalation, capabilities
# 5. kubectl patch --type='json' for precise additions
# 6. kubectl rollout resume to unpause
# 7. kubectl rollout status to wait for completion
# 8. capabilities.drop: ["ALL"] removes all Linux capabilities
# 9. capabilities.add: ["NET_BIND_SERVICE"] adds specific capability back
#===============================================================================
# SYS_ADMIN - Various admin operations
# NET_ADMIN - Network administration
# ALL - All capabilities
#
# Best Practice: DROP ALL, then ADD only what's needed
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: Edit deployment to add securityContext (60 sec)
  kubectl edit deployment secure-app -n secure-ns
  # Add pod-level (under spec.template.spec):
  #   securityContext:
  #     runAsUser: 10000
  # Add container-level (under containers[0]):
  #   securityContext:
  #     allowPrivilegeEscalation: false
  #     capabilities:
  #       add: ["NET_BIND_SERVICE"]
  Save (:wq)

Step 2: Resume deployment if paused (10 sec)
  kubectl rollout resume deployment/secure-app -n secure-ns

Step 3: Verify (20 sec)
  kubectl rollout status deployment/secure-app -n secure-ns

REMEMBER: Pod-level = runAsUser, runAsGroup, fsGroup
          Container-level = allowPrivilegeEscalation, capabilities
================================================================================
'
