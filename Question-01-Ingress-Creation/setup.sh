#!/bin/bash
# Question 1: Ingress Creation - Setup

set -e
echo "🔧 Setting up Question 1 environment..."

# Create namespace
kubectl create namespace external --dry-run=client -o yaml | kubectl apply -f -

# Clean up any existing resources
kubectl delete ingress ingress-name -n external --ignore-not-found=true 2>/dev/null || true
kubectl delete svc webapp -n external --ignore-not-found=true 2>/dev/null || true
kubectl delete deployment webapp -n external --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the webapp deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: external
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# Create the webapp service on port 8080
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: webapp
  namespace: external
spec:
  selector:
    app: webapp
  ports:
  - port: 8080
    targetPort: 80
EOF

# Wait for deployment
kubectl rollout status deployment/webapp -n external --timeout=60s

echo ""
echo "✅ Namespace 'external' created"
echo "✅ Deployment 'webapp' created"
echo "✅ Service 'webapp' created (port 8080)"
echo ""
echo "📍 Current state:"
kubectl get all -n external
echo ""
echo "🎯 Environment ready!"
