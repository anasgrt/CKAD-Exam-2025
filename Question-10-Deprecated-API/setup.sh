#!/bin/bash
# Question 10: Fix Deprecated API Version - Setup

set -e
echo "🔧 Setting up Question 10 environment..."

# Create namespace
kubectl create namespace migration-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment legacy-app -n migration-ns --ignore-not-found=true 2>/dev/null || true

# Create the legacy manifest with apps/v1beta1 API (deprecated)
# Professional-Sea4743: "apps/betav1 version, put selector accordingly"
cat > /tmp/legacy-deployment.yaml <<'EOF'
# WARNING: This manifest uses deprecated API version!
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: legacy-app
  namespace: migration-ns
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: legacy-app
        version: v1
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

echo ""
echo "✅ Namespace 'migration-ns' created"
echo "✅ Legacy manifest saved to /tmp/legacy-deployment.yaml"
echo ""
echo "📍 Contents of /tmp/legacy-deployment.yaml:"
echo "----------------------------------------"
cat /tmp/legacy-deployment.yaml
echo ""
echo "----------------------------------------"
echo ""
echo "🔴 This manifest uses deprecated API (apps/v1beta1)"
echo "   Update it to use apps/v1 and add the required selector field"
echo ""
echo "🎯 Environment ready!"
