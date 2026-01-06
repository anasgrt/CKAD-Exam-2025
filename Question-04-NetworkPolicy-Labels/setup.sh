#!/bin/bash
# Question 4: NetworkPolicy - Adjust Pod Labels - Setup
# Pattern: 3 pods (front, api, db) + 4 NetworkPolicies (deny-all, allow-all, allow-front-to-api, allow-api-to-db)

set -e
echo "🔧 Setting up Question 4 environment..."

# Create namespace
kubectl create namespace app-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up existing resources
kubectl delete networkpolicy --all -n app-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete pod --all -n app-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create front-pod with correct labels
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: front-pod
  namespace: app-ns
  labels:
    app: front
    tier: frontend
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
EOF

# Create api-pod WITHOUT the required labels (this is the pod student needs to fix)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  namespace: app-ns
  labels:
    app: api
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Create db-pod with correct labels
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  namespace: app-ns
  labels:
    app: db
    tier: database
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
EOF

# Create 4 NetworkPolicies (matching EXACT real exam pattern from mailaffy: deny-all, allow-all, + 2 more)

# Policy 1: deny-all - Default deny all ingress traffic
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: app-ns
spec:
  podSelector: {}
  policyTypes:
  - Ingress
EOF

# Policy 2: allow-all - allows all traffic for tier=unrestricted (decoy - not used in solution)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
  namespace: app-ns
spec:
  podSelector:
    matchLabels:
      tier: unrestricted
  policyTypes:
  - Ingress
  ingress:
  - {}
EOF

# Policy 3: allow-front-to-api - allows frontend tier to send to api tier
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front-to-api
  namespace: app-ns
spec:
  podSelector:
    matchLabels:
      tier: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
EOF

# Policy 4: allow-api-to-db - allows api tier to access database tier
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: app-ns
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: api
    ports:
    - protocol: TCP
      port: 3306
EOF

# Wait for pods
echo "⏳ Waiting for pods to start..."
kubectl wait --for=condition=Ready pod/api-pod -n app-ns --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/front-pod -n app-ns --timeout=60s 2>/dev/null || true
kubectl wait --for=condition=Ready pod/db-pod -n app-ns --timeout=60s 2>/dev/null || true

echo ""
echo "✅ Namespace 'app-ns' created"
echo "✅ Pods created: front-pod, api-pod, db-pod"
echo "✅ 4 NetworkPolicies created: deny-all, allow-all, allow-front-to-api, allow-api-to-db"
echo ""
echo "📍 Current pods and labels:"
kubectl get pods -n app-ns --show-labels
echo ""
echo "📍 NetworkPolicies:"
kubectl get networkpolicy -n app-ns
echo ""
echo "🎯 Environment ready!"
echo ""
echo "⚠️  IMPORTANT: Do NOT modify any NetworkPolicies! Only modify pod labels."
