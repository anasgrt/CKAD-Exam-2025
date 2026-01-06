#!/bin/bash
# Question 8: Canary Deployment - Setup

set -e
echo "🔧 Setting up Question 8 environment..."

# Create namespace
kubectl create namespace canary-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment web-app web-app-canary -n canary-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete svc web-service -n canary-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the stable deployment with 5 replicas (Professional-Sea4743 pattern: 10 pod limit, 5 stable)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: canary-ns
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web-app
      version: stable
  template:
    metadata:
      labels:
        app: web-app
        version: stable
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
EOF

# Create the service that selects app=web-app
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: canary-ns
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

# Wait for deployment
kubectl rollout status deployment/web-app -n canary-ns --timeout=60s

echo ""
echo "✅ Namespace 'canary-ns' created"
echo "✅ Deployment 'web-app' created (5 replicas, nginx:1.19)"
echo "✅ Service 'web-service' created (selector: app=web-app)"
echo "⚠️  CONSTRAINT: Maximum 10 pods total allowed in this namespace"
echo ""
echo "📍 Current deployments:"
kubectl get deployments -n canary-ns
echo ""
echo "📍 Current endpoints:"
kubectl get endpoints web-service -n canary-ns
echo ""
echo "🎯 Environment ready!"
