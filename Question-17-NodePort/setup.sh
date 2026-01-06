#!/bin/bash
# Question 17: Expose Deployment with NodePort - Setup

set -e
echo "🔧 Setting up Question 17 environment..."

# Create namespace
kubectl create namespace web-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete svc frontend-service -n web-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete deployment frontend-app -n web-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the frontend-app deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: web-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-app
  template:
    metadata:
      labels:
        app: frontend-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 8080
        command: ["/bin/sh", "-c"]
        args:
        - |
          sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf
          nginx -g 'daemon off;'
EOF

# Wait for deployment
kubectl rollout status deployment/frontend-app -n web-ns --timeout=60s

echo ""
echo "✅ Namespace 'web-ns' created"
echo "✅ Deployment 'frontend-app' created (container port 8080)"
echo ""
echo "📍 Current deployments:"
kubectl get deployments -n web-ns
echo ""
echo "📍 Pod labels:"
kubectl get pods -n web-ns --show-labels
echo ""
echo "🎯 Environment ready!"
