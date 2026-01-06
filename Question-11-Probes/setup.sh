#!/bin/bash
# Question 11: Modify Deployment Twice, Then Rollback - Setup

set -e
echo "🔧 Setting up Question 11 environment..."

# Create namespace
kubectl create namespace health-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment web-app -n health-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete configmap nginx-config -n health-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create nginx config that serves /ready endpoint
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: health-ns
data:
  default.conf: |
    server {
        listen 8080;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }

        location /ready {
            return 200 'ready';
            add_header Content-Type text/plain;
        }

        location /health {
            return 200 'healthy';
            add_header Content-Type text/plain;
        }
    }
EOF

# Create deployment WITHOUT readiness probe (needs to be added)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: health-ns
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
        image: nginx:1.21
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: config
        configMap:
          name: nginx-config
EOF

# Wait for deployment
kubectl rollout status deployment/web-app -n health-ns --timeout=60s 2>/dev/null || true

echo ""
echo "✅ Namespace 'health-ns' created"
echo "✅ Deployment 'web-app' created (WITHOUT readiness probe)"
echo ""
echo "📍 Current deployment status:"
kubectl get deployment web-app -n health-ns
echo ""
echo "📍 Note: Deployment has no readiness probe configured"
echo ""
echo "🎯 Environment ready!"
