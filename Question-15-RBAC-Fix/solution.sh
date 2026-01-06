#!/bin/bash
#===============================================================================
# SOLUTION: Question 15 - Find Existing ServiceAccount and Apply to Deployment
# Pattern: Effective_Scallion63 (96%) - "Find existing SA and apply it"
#===============================================================================

# Step 1: List all ServiceAccounts in the namespace
echo "📋 Step 1: List available ServiceAccounts"
kubectl get sa -n rbac-ns

# Step 2: Check the existing Role
echo ""
echo "📋 Step 2: Check the existing Role"
kubectl get role -n rbac-ns
kubectl describe role pod-list-role -n rbac-ns

# Step 3: Check the RoleBinding to find which SA has permissions
echo ""
echo "📋 Step 3: Check RoleBinding to find the correct ServiceAccount"
kubectl get rolebinding -n rbac-ns -o yaml | grep -A5 "subjects:"
# Or more specifically:
kubectl get rolebinding pod-list-binding -n rbac-ns -o jsonpath='{.subjects[0].name}'
echo ""

# Step 4: Test which ServiceAccount has the right permissions
echo ""
echo "📋 Step 4: Test permissions for each ServiceAccount"
echo "log-reader-sa: $(kubectl auth can-i list pods --as=system:serviceaccount:rbac-ns:log-reader-sa -n rbac-ns)"
echo "metrics-sa: $(kubectl auth can-i list pods --as=system:serviceaccount:rbac-ns:metrics-sa -n rbac-ns)"
echo "scraper-sa: $(kubectl auth can-i list pods --as=system:serviceaccount:rbac-ns:scraper-sa -n rbac-ns)"
# scraper-sa is the one with permissions!

# Step 5: Update the Deployment to use the correct ServiceAccount
echo ""
echo "📋 Step 5: Update Deployment to use scraper-sa"
kubectl set serviceaccount deployment/scraper-app scraper-sa -n rbac-ns

# Step 6: Wait for rollout
echo ""
echo "📋 Step 6: Wait for rollout"
kubectl rollout status deployment/scraper-app -n rbac-ns

# Step 7: Verify the Deployment now uses the correct SA
echo ""
echo "📋 Step 7: Verify ServiceAccount"
kubectl get deployment scraper-app -n rbac-ns -o jsonpath='{.spec.template.spec.serviceAccountName}'
echo ""

# Step 8: Test from inside the pod
echo ""
echo "📋 Step 8: Test listing pods from inside the pod"
POD=$(kubectl get pod -n rbac-ns -l app=scraper -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD -n rbac-ns -- kubectl get pods -n rbac-ns

#===============================================================================
# KEY POINTS: Finding the Correct ServiceAccount
#===============================================================================
# 1. List all ServiceAccounts: kubectl get sa -n <ns>
# 2. Check RoleBindings: kubectl get rolebinding -n <ns> -o yaml
# 3. Look at "subjects" field to see which SA is bound
# 4. Test with: kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>
# 5. Apply to deployment: kubectl set serviceaccount deployment/<name> <sa> -n <ns>
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds)
================================================================================
Step 1: Find which SA has permissions (20 sec)
  kubectl get rolebinding -n rbac-ns -o yaml | grep -A3 "subjects:"
  # OR test each SA:
  kubectl auth can-i list pods --as=system:serviceaccount:rbac-ns:scraper-sa -n rbac-ns

Step 2: Apply the correct SA to deployment (10 sec)
  kubectl set serviceaccount deployment/scraper-app scraper-sa -n rbac-ns

Step 3: Verify (10 sec)
  kubectl rollout status deployment/scraper-app -n rbac-ns

KEY: Use kubectl auth can-i to TEST permissions quickly!
     Format: --as=system:serviceaccount:<namespace>:<sa-name>
================================================================================
'
