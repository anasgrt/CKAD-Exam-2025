#!/bin/bash
#===============================================================================
# SOLUTION: Question 17 - Expose Deployment with NodePort
#===============================================================================

# Method 1: Imperative command + patch
kubectl expose deployment frontend-app -n web-ns \
  --name=frontend-service \
  --type=NodePort \
  --port=80 \
  --target-port=8080

#-------------------------------------------------------------------------------
# METHOD A: Using kubectl edit to set specific NodePort
#-------------------------------------------------------------------------------
# kubectl edit svc frontend-service -n web-ns
#
# Find the ports section and add/modify nodePort:
#
#   spec:
#     type: NodePort
#     ports:
#     - port: 80
#       targetPort: 8080
#       nodePort: 30080    # ADD THIS LINE
#       protocol: TCP
#
# Save and exit (:wq in vim)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# METHOD B: Patch to set specific NodePort (alternative)
#-------------------------------------------------------------------------------
kubectl patch svc frontend-service -n web-ns \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value": 30080}]'

# Method 2: YAML manifest (Recommended for specific nodePort)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: web-ns
spec:
  type: NodePort
  selector:
    app: frontend-app
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
EOF

# Verify
kubectl get svc frontend-service -n web-ns
kubectl get endpoints frontend-service -n web-ns

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. NodePort exposes service on each node's IP at a static port (30000-32767)
# 2. Service port (80) is the port clients use within cluster
# 3. Target port (8080) is the container port
# 4. NodePort (30080) is the external port on each node
# 5. kubectl expose doesn't allow setting specific nodePort - use patch or YAML
# 6. Selector must match pod labels for endpoints to be populated
# 7. Access: curl http://<node-ip>:30080
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 45 seconds)
================================================================================
Step 1: Expose deployment (10 sec)
  kubectl expose deployment frontend-app -n web-ns \
    --name=frontend-service --type=NodePort \
    --port=80 --target-port=8080

Step 2: Set specific nodePort with edit (20 sec)
  kubectl edit svc frontend-service -n web-ns
  # Under ports[0] add:
  #   nodePort: 30080
  Save (:wq)

Step 3: Verify (15 sec)
  kubectl get svc frontend-service -n web-ns

TIP: kubectl expose cannot set specific nodePort, so edit after!
     NodePort range: 30000-32767
================================================================================
'
