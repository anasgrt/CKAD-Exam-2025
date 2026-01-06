#!/bin/bash
#===============================================================================
# SOLUTION: Question 4 - NetworkPolicy - Adjust Pod Labels
# Exam Pattern: 3 pods (front, api, db) + 4 policies (deny-all, allow-all, allow-front-to-api, allow-api-to-db)
#===============================================================================

# Step 1: List all NetworkPolicies and understand what they do
echo "📋 Step 1: Examine NetworkPolicies"
kubectl get networkpolicy -n app-ns
echo ""

# Step 2: Examine each policy to understand the selectors
echo "📋 Step 2: Examine each NetworkPolicy"
echo "--- deny-all ---"
kubectl describe networkpolicy deny-all -n app-ns | grep -A10 "Spec:"
# This policy: applies to ALL pods (empty selector), denies all ingress by default

echo ""
echo "--- allow-all ---"
kubectl describe networkpolicy allow-all -n app-ns | grep -A10 "Spec:"
# This policy: applies to tier=unrestricted (DECOY - not relevant to our pods)

echo ""
echo "--- allow-front-to-api ---"
kubectl describe networkpolicy allow-front-to-api -n app-ns | grep -A10 "Spec:"
# This policy: applies to pods with tier=api, allows ingress from tier=frontend

echo ""
echo "--- allow-api-to-db ---"
kubectl describe networkpolicy allow-api-to-db -n app-ns | grep -A10 "Spec:"
# This policy: applies to pods with tier=database, allows ingress from tier=api

# Step 3: Check current labels on api-pod
echo ""
echo "📋 Step 3: Check current pod labels"
kubectl get pod api-pod -n app-ns --show-labels
# Notice: api-pod only has app=api, but needs tier=api to:
# 1. Be selected by allow-front-to-api (to receive traffic from frontend)
# 2. Be allowed by allow-api-to-db (to send traffic to database)

# Step 4: Add the required label to api-pod
echo ""
echo "📋 Step 4: Add required label to api-pod"
kubectl label pod api-pod -n app-ns tier=api

# Verify the label was added
echo ""
echo "📋 Step 5: Verify labels were applied"
kubectl get pod api-pod -n app-ns --show-labels

echo ""
echo "📋 All pods with labels:"
kubectl get pods -n app-ns --show-labels

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. READ ALL NetworkPolicies first to understand the traffic flow design
# 2. deny-all blocks everything by default (empty podSelector = all pods)
# 3. allow-all is a DECOY - it applies to tier=unrestricted which no pod has
# 4. allow-front-to-api: pods with tier=api receive traffic from tier=frontend
# 5. allow-api-to-db: pods with tier=database receive traffic from tier=api
# 6. Solution: Add tier=api label to api-pod to enable both flows
# 7. kubectl label pod <name> <key>=<value> adds labels without restarting pod
# 8. The exam tests your ability to analyze multiple policies and pick the right one
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: List all NetworkPolicies and identify the pattern (30 sec)
  kubectl get netpol -n app-ns
  kubectl describe netpol -n app-ns | grep -A5 "PodSelector\|Allowing"

Step 2: Check what label is needed (30 sec)
  - Look at allow-front-to-api: podSelector tier=api
  - Look at allow-api-to-db: from podSelector tier=api
  - api-pod needs tier=api label!

Step 3: Add the label (10 sec)
  kubectl label pod api-pod -n app-ns tier=api

Step 4: Verify (20 sec)
  kubectl get pods -n app-ns --show-labels

KEY INSIGHT: You are NOT creating/modifying NetworkPolicies!
Just add the RIGHT LABEL to the pod so it matches existing policies.
================================================================================
'

