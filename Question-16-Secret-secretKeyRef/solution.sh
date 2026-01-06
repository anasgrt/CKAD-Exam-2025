#!/bin/bash
#===============================================================================
# SOLUTION: Question 16 - Secret with Multiple Keys
#===============================================================================

# Step 1: Create the Secret (imperative method - fast for exam)
kubectl create secret generic db-secret -n secret-ns \
  --from-literal=DB_HOST=mysql.database.svc \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=secret123 \
  --from-literal=DB_NAME=myapp

# OR using YAML (stringData auto-encodes to base64)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: secret-ns
type: Opaque
stringData:
  DB_HOST: mysql.database.svc
  DB_USER: admin
  DB_PASSWORD: secret123
  DB_NAME: myapp
EOF

# Step 2: Update the Deployment to use secretKeyRef
# Method A: Using kubectl edit
kubectl edit deployment db-app -n secret-ns
# Replace the env section with secretKeyRef for each variable:
#   env:
#   - name: DB_HOST
#     valueFrom:
#       secretKeyRef:
#         name: db-secret
#         key: DB_HOST
#   - name: DB_USER
#     valueFrom:
#       secretKeyRef:
#         name: db-secret
#         key: DB_USER
#   - name: DB_PASSWORD
#     valueFrom:
#       secretKeyRef:
#         name: db-secret
#         key: DB_PASSWORD
#   - name: DB_NAME
#     valueFrom:
#       secretKeyRef:
#         name: db-secret
#         key: DB_NAME

# Method B: Using kubectl patch (replace entire env array)
kubectl patch deployment db-app -n secret-ns --type='json' -p='[
  {"op": "replace", "path": "/spec/template/spec/containers/0/env", "value": [
    {"name": "DB_HOST", "valueFrom": {"secretKeyRef": {"name": "db-secret", "key": "DB_HOST"}}},
    {"name": "DB_USER", "valueFrom": {"secretKeyRef": {"name": "db-secret", "key": "DB_USER"}}},
    {"name": "DB_PASSWORD", "valueFrom": {"secretKeyRef": {"name": "db-secret", "key": "DB_PASSWORD"}}},
    {"name": "DB_NAME", "valueFrom": {"secretKeyRef": {"name": "db-secret", "key": "DB_NAME"}}}
  ]}
]'

# Method C: Export, edit, apply
kubectl get deployment db-app -n secret-ns -o yaml > /tmp/db-app.yaml
# Edit /tmp/db-app.yaml to use secretKeyRef
kubectl apply -f /tmp/db-app.yaml

# Step 3: Verify rollout
kubectl rollout status deployment/db-app -n secret-ns

# Step 4: Verify Secret
kubectl get secret db-secret -n secret-ns -o yaml

# Step 5: Verify Deployment and env vars
kubectl get deployment db-app -n secret-ns
kubectl get pods -n secret-ns -l app=db-app
POD_NAME=$(kubectl get pods -n secret-ns -l app=db-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD_NAME" -n secret-ns -- env | grep DB_

#===============================================================================
# SECRET TYPES:
#===============================================================================
# Opaque: Default, arbitrary key-value pairs
# kubernetes.io/dockerconfigjson: Docker registry credentials
# kubernetes.io/tls: TLS certificate and key
# kubernetes.io/basic-auth: Username and password
# kubernetes.io/ssh-auth: SSH private key
#===============================================================================

#===============================================================================
# USING SECRETS WITH DEPLOYMENTS:
#===============================================================================
# 1. env with secretKeyRef - Load specific keys as env vars:
#    env:
#    - name: DB_HOST
#      valueFrom:
#        secretKeyRef:
#          name: db-secret
#          key: DB_HOST
#    - name: DB_PASSWORD
#      valueFrom:
#        secretKeyRef:
#          name: db-secret
#          key: DB_PASSWORD
#
# 2. envFrom - Load ALL keys as env vars (alternative):
#    envFrom:
#    - secretRef:
#        name: db-secret
#
# 3. Volume mount - Mount secret as files:
#    volumes:
#    - name: secret-vol
#      secret:
#        secretName: db-secret
#    containers:
#    - volumeMounts:
#      - name: secret-vol
#        mountPath: /etc/secrets
#        readOnly: true
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: Create secret imperatively (15 sec)
  kubectl create secret generic db-secret -n secret-ns \
    --from-literal=DB_HOST=mysql.database.svc \
    --from-literal=DB_USER=admin \
    --from-literal=DB_PASSWORD=secret123 \
    --from-literal=DB_NAME=myapp

Step 2: Edit deployment to use secretKeyRef (60 sec)
  kubectl edit deployment db-app -n secret-ns
  # Replace env section with secretKeyRef for EACH variable:
  #   env:
  #   - name: DB_HOST
  #     valueFrom:
  #       secretKeyRef:
  #         name: db-secret
  #         key: DB_HOST
  #   - name: DB_USER
  #     ... (same pattern)
  Save (:wq)

Step 3: Verify (15 sec)
  kubectl exec <pod> -n secret-ns -- env | grep DB_

WARNING: secretKeyRef loads INDIVIDUAL keys as separate env vars!
         This is different from envFrom which loads ALL keys at once.
================================================================================
'
