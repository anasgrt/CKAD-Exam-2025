#!/bin/bash
#===============================================================================
# SOLUTION: Question 11 - Modify Deployment Twice, Then Rollback
# Pattern: Effective_Scallion63 (96%) - "Modify deployment twice, then rollback"
#===============================================================================

# Step 1: Check current deployment status
echo "📋 Step 1: Check current deployment"
kubectl get deployment web-app -n health-ns
echo ""
echo "Current image:"
kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""

# Step 2: FIRST MODIFICATION - Add readiness probe
echo ""
echo "📋 Step 2: First modification - Add readiness probe"

#-------------------------------------------------------------------------------
# METHOD A: Using kubectl edit (RECOMMENDED for exam - visual editing)
#-------------------------------------------------------------------------------
# kubectl edit deployment web-app -n health-ns
#
# Find the containers section and add readinessProbe:
#
#   spec:
#     template:
#       spec:
#         containers:
#         - name: nginx
#           image: nginx:1.21
#           # ADD THIS SECTION:
#           readinessProbe:
#             httpGet:
#               path: /healthz
#               port: 8080
#             initialDelaySeconds: 5
#             periodSeconds: 10
#
# Save and exit (:wq in vim)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# METHOD B: Using kubectl patch (alternative - single command)
#-------------------------------------------------------------------------------
kubectl patch deployment web-app -n health-ns --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/readinessProbe",
    "value": {
      "httpGet": {
        "path": "/healthz",
        "port": 8080
      },
      "initialDelaySeconds": 5,
      "periodSeconds": 10
    }
  }
]'

# Wait for first rollout
kubectl rollout status deployment/web-app -n health-ns

# Step 3: SECOND MODIFICATION - Update image to nginx:1.22
echo ""
echo "📋 Step 3: Second modification - Update image to nginx:1.22"
kubectl set image deployment/web-app nginx=nginx:1.22 -n health-ns

# Wait for second rollout
kubectl rollout status deployment/web-app -n health-ns

# Step 4: Check rollout history
echo ""
echo "📋 Step 4: Check rollout history"
kubectl rollout history deployment/web-app -n health-ns

# Step 5: Verify current state (should have probe + nginx:1.22)
echo ""
echo "📋 Step 5: Verify current state before rollback"
echo "Image: $(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].image}')"
echo "Has readiness probe: $(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"

# Step 6: ROLLBACK to previous revision
echo ""
echo "📋 Step 6: Rollback to previous revision"
kubectl rollout undo deployment/web-app -n health-ns

# Wait for rollback
kubectl rollout status deployment/web-app -n health-ns

# Step 7: Verify after rollback (should have probe + nginx:1.21)
echo ""
echo "📋 Step 7: Verify state after rollback"
echo "Image: $(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].image}')"
echo "Has readiness probe: $(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"

#===============================================================================
# ROLLOUT COMMANDS:
#===============================================================================
# kubectl rollout status deployment/<name> -n <ns>    # Watch rollout progress
# kubectl rollout history deployment/<name> -n <ns>   # View revision history
# kubectl rollout undo deployment/<name> -n <ns>      # Rollback to previous
# kubectl rollout undo deployment/<name> -n <ns> --to-revision=2  # Specific revision
# kubectl rollout pause deployment/<name> -n <ns>     # Pause rollout
# kubectl rollout resume deployment/<name> -n <ns>    # Resume rollout
#===============================================================================

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. Edit existing deployment, don't delete and recreate
# 2. Readiness probe determines when pod receives traffic
# 3. Use kubectl edit or kubectl patch to modify deployment in-place
# 4. Probe configuration goes under containers[].readinessProbe
# 5. Changes trigger a rolling update automatically
# 6. "kubectl rollout undo" goes to PREVIOUS revision
# 7. Use "--to-revision=N" to go to specific revision
#===============================================================================

#===============================================================================
# PROBE PARAMETERS:
#===============================================================================
# initialDelaySeconds: Seconds after container starts before probe runs
# periodSeconds: How often to perform the probe (default 10)
# timeoutSeconds: Seconds to wait for probe response (default 1)
# successThreshold: Min consecutive successes (default 1)
# failureThreshold: Min consecutive failures (default 3)
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: Add readiness probe with kubectl edit (30 sec)
  kubectl edit deployment web-app -n health-ns
  # Add under containers[0]:
  #   readinessProbe:
  #     httpGet:
  #       path: /ready
  #       port: 8080
  #     initialDelaySeconds: 5
  #     periodSeconds: 10
  Save (:wq)

Step 2: Update image (10 sec)
  kubectl set image deployment/web-app nginx=nginx:1.22 -n health-ns

Step 3: Rollback to previous (10 sec)
  kubectl rollout undo deployment/web-app -n health-ns

Verify: kubectl rollout history deployment/web-app -n health-ns

TIP: kubectl edit is FASTEST for adding probes (visual, catches errors)
     kubectl set image is FASTEST for changing images
     kubectl rollout undo is FASTEST for rollback
================================================================================
'
