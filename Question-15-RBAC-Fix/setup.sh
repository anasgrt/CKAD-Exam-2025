#!/bin/bash
# Question 15: Find Existing ServiceAccount and Apply to Deployment - Setup

set -e
echo "🔧 Setting up Question 15 environment..."

# Create namespace
kubectl create namespace rbac-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment scraper-app -n rbac-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete role --all -n rbac-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete rolebinding --all -n rbac-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete sa log-reader-sa metrics-sa scraper-sa -n rbac-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create MULTIPLE ServiceAccounts (student must find the correct one)
kubectl create serviceaccount log-reader-sa -n rbac-ns
kubectl create serviceaccount metrics-sa -n rbac-ns
kubectl create serviceaccount scraper-sa -n rbac-ns

# Create Role that allows listing pods
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-list-role
  namespace: rbac-ns
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
EOF

# Create RoleBinding that binds ONLY scraper-sa to the role (this is the correct SA!)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-list-binding
  namespace: rbac-ns
subjects:
- kind: ServiceAccount
  name: scraper-sa
  namespace: rbac-ns
roleRef:
  kind: Role
  name: pod-list-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Create Deployment using WRONG ServiceAccount (default)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scraper-app
  namespace: rbac-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scraper
  template:
    metadata:
      labels:
        app: scraper
    spec:
      # Using default SA - needs to be changed to the correct existing SA
      containers:
      - name: scraper
        image: bitnami/kubectl:latest
        command: ["sleep", "3600"]
EOF

# Wait for deployment
kubectl rollout status deployment/scraper-app -n rbac-ns --timeout=60s 2>/dev/null || true

echo ""
echo "✅ Namespace 'rbac-ns' created"
echo "✅ Multiple ServiceAccounts created"
echo "✅ Role and RoleBinding already exist"
echo "✅ Deployment 'scraper-app' created (using default ServiceAccount)"
echo ""
echo "📍 Available ServiceAccounts:"
kubectl get sa -n rbac-ns
echo ""
echo "📍 Existing Roles:"
kubectl get role -n rbac-ns
echo ""
echo "📍 Existing RoleBindings:"
kubectl get rolebindings -n rbac-ns
echo ""
echo "📍 Current Deployment ServiceAccount:"
kubectl get deployment scraper-app -n rbac-ns -o jsonpath='{.spec.template.spec.serviceAccountName}' && echo " (empty = default)"
echo ""
echo "🔴 The Deployment cannot list pods - find the correct existing SA and apply it!"
echo ""
echo "🎯 Environment ready!"
