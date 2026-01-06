#!/bin/bash
# Question 5: ResourceQuota and LimitRange Compliance - Setup

set -e
echo "🔧 Setting up Question 5 environment..."

# Create namespace
kubectl create namespace limited-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete resourcequota compute-quota -n limited-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete limitrange resource-limits -n limited-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete pod quota-pod -n limited-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the LimitRange (Professional-Sea4743 pattern: memory 640 limit)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: limited-ns
spec:
  limits:
  - type: Container
    max:
      cpu: "1"
      memory: 640Mi
    min:
      cpu: 100m
      memory: 64Mi
    default:
      cpu: 500m
      memory: 320Mi
    defaultRequest:
      cpu: 250m
      memory: 160Mi
EOF

# Create the ResourceQuota
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: limited-ns
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
EOF

echo ""
echo "✅ Namespace 'limited-ns' created"
echo "✅ LimitRange 'resource-limits' created"
echo "✅ ResourceQuota 'compute-quota' created"
echo ""
echo "📍 Use kubectl describe to examine the resource constraints"
echo ""
echo "🎯 Environment ready!"
