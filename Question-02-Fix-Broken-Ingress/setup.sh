#!/bin/bash
# Question 2: Fix Broken Ingress - Setup

set -e
echo "🔧 Setting up Question 2 environment..."

# Create namespace
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete ingress web-ingress -n production --ignore-not-found=true 2>/dev/null || true
kubectl delete svc web-service -n production --ignore-not-found=true 2>/dev/null || true
kubectl delete deployment web-app -n production --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the web-app deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# Create the correct service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: production
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

# Create BROKEN ingress (wrong service name, wrong port, wrong host spelling)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: production
spec:
  rules:
  - host: app.exmple.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 8080
EOF

# Wait for deployment
kubectl rollout status deployment/web-app -n production --timeout=60s

echo ""
echo "✅ Namespace 'production' created"
echo "✅ Deployment 'web-app' created"
echo "✅ Service 'web-service' created"
echo "✅ Ingress 'web-ingress' created (BROKEN - needs fixing)"
echo ""
echo "📍 Current state:"
kubectl get all,ingress -n production
echo ""
echo "🔴 The Ingress is returning 404 errors - fix it!"
echo ""
echo "🎯 Environment ready!"
