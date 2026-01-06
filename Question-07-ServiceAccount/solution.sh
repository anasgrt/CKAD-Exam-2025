#!/bin/bash
#===============================================================================
# SOLUTION: Question 7 - RBAC: ServiceAccount, Role, and RoleBinding
#===============================================================================

# Step 1: Check pod logs for permission error
echo "📋 Step 1: Verify the Forbidden error"
kubectl logs -l app=secure-app -n secure-ns --tail=5

# Step 2: Create ServiceAccount
echo ""
echo "📋 Step 2: Create ServiceAccount"
kubectl create serviceaccount pod-reader-sa -n secure-ns

# Step 3: Create Role with pod list permissions
echo ""
echo "📋 Step 3: Create Role"
kubectl create role pod-reader-role \
  --verb=get,list,watch \
  --resource=pods \
  -n secure-ns

# Step 4: Create RoleBinding to bind Role to ServiceAccount
echo ""
echo "📋 Step 4: Create RoleBinding"
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader-role \
  --serviceaccount=secure-ns:pod-reader-sa \
  -n secure-ns

# Step 5: Verify permissions work
echo ""
echo "📋 Step 5: Verify permissions"
kubectl auth can-i list pods -n secure-ns --as=system:serviceaccount:secure-ns:pod-reader-sa

# Step 6: Update deployment to use the new ServiceAccount
echo ""
echo "📋 Step 6: Update deployment to use new ServiceAccount"
kubectl set serviceaccount deployment/secure-app pod-reader-sa -n secure-ns

# Alternative using edit:
# kubectl edit deployment secure-app -n secure-ns
# Add under spec.template.spec:
#   serviceAccountName: pod-reader-sa

# Wait for rollout
echo ""
echo "📋 Step 7: Wait for rollout"
kubectl rollout status deployment/secure-app -n secure-ns

# Verify deployment uses correct SA
echo ""
echo "📋 Step 8: Verify deployment uses correct SA"
kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.serviceAccountName}'
echo ""

# Check logs no longer show Forbidden
kubectl logs -l app=secure-app -n secure-ns --tail=5

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. RBAC workflow: ServiceAccount → Role → RoleBinding → Assign to workload
# 2. kubectl create serviceaccount <name> -n <ns>
# 3. kubectl create role <name> --verb=get,list,watch --resource=pods -n <ns>
# 4. kubectl create rolebinding <name> --role=<role> --serviceaccount=<ns>:<sa> -n <ns>
# 5. kubectl set serviceaccount deployment/<name> <sa-name> -n <ns>
# 6. serviceAccountName goes under spec.template.spec (pod spec level)
# 7. Test permissions: kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>
# 8. Role = namespaced permissions, ClusterRole = cluster-wide permissions
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds) - ALL IMPERATIVE!
================================================================================
1. Create ServiceAccount (5 sec):
   kubectl create sa pod-reader-sa -n secure-ns

2. Create Role (10 sec):
   kubectl create role pod-reader-role --verb=get,list,watch --resource=pods -n secure-ns

3. Create RoleBinding (10 sec):
   kubectl create rolebinding pod-reader-binding \
     --role=pod-reader-role --serviceaccount=secure-ns:pod-reader-sa -n secure-ns

4. Attach SA to Deployment (10 sec):
   kubectl set serviceaccount deployment/secure-app pod-reader-sa -n secure-ns

Verify (10 sec):
   kubectl auth can-i list pods -n secure-ns --as=system:serviceaccount:secure-ns:pod-reader-sa

REMEMBER: serviceaccount format is <namespace>:<sa-name>
================================================================================
'
