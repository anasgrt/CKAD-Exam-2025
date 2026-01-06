#!/bin/bash
# Question 16: Secret with Multiple Keys - Setup

set -e
echo "🔧 Setting up Question 16 environment..."

# Create namespace
kubectl create namespace secret-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment db-app -n secret-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete secret db-secret -n secret-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create existing deployment WITH individual env vars (not using secret)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
  namespace: secret-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: DB_HOST
          value: "localhost"
        - name: DB_USER
          value: "root"
        - name: DB_PASSWORD
          value: "oldpassword"
        - name: DB_NAME
          value: "testdb"
EOF

sleep 3

echo ""
echo "✅ Namespace 'secret-ns' created"
echo "✅ Deployment 'db-app' created (using individual env vars, NOT from secret)"
echo ""
echo "📍 Current deployment env configuration:"
kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env}' | jq . 2>/dev/null || kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env}'
echo ""
echo ""
echo "📍 Your tasks:"
echo "   1. Create Secret 'db-secret' with keys:"
echo "      - DB_HOST=mysql.database.svc"
echo "      - DB_USER=admin"
echo "      - DB_PASSWORD=secret123"
echo "      - DB_NAME=myapp"
echo ""
echo "   2. Update the Deployment 'db-app' to use secretKeyRef for each env var"
echo "      (replace the hardcoded values with secretKeyRef)"
echo ""
echo "🎯 Environment ready!"
