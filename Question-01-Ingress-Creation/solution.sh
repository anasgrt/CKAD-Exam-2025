#!/bin/bash
#===============================================================================
# SOLUTION: Question 1 - Ingress Creation
#===============================================================================

# Method 1: Using YAML manifest (Recommended)
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-name
  namespace: external
spec:
  ingressClassName: nginx-exam
  rules:
  - host: external.app.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: webapp
            port:
              number: 8080
EOF

# Method 2: Imperative command - FASTEST for exam! (Single command)
kubectl create ingress ingress-name \
  --rule="external.app.local/*=webapp:8080" \
  --class=nginx-exam \
  -n external

# Method 3: Imperative with dry-run (to preview YAML first)
# kubectl create ingress ingress-name \
#   --rule="external.app.local/*=webapp:8080" \
#   --class=nginx-exam \
#   -n external \
#   --dry-run=client -o yaml

# Verification commands
kubectl get ingress -n external
kubectl describe ingress ingress-name -n external

#===============================================================================
# KEY POINTS:
#===============================================================================
# 1. apiVersion: networking.k8s.io/v1 (not v1beta1)
# 2. ingressClassName: nginx-exam (not annotation)
# 3. pathType: Prefix is required for v1
# 4. Backend uses service.name and service.port.number structure
# 5. Host is the external URL to route traffic from
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 30 seconds)
================================================================================
kubectl create ingress ingress-name \
  --rule="external.app.local/*=webapp:8080" \
  --class=nginx-exam \
  -n external

That is it! Single command creates the complete Ingress.
The /*= syntax means pathType=Prefix, /= would mean pathType=Exact
================================================================================
'
