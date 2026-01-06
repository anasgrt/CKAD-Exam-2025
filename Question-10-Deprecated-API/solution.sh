#!/bin/bash
#===============================================================================
# SOLUTION: Question 10 - Fix Deprecated API Version
# Pattern: "apps/betav1 version, put selector accordingly"
#===============================================================================

# Step 1: Review the legacy manifest
cat /tmp/legacy-deployment.yaml

# Step 2: Create the corrected manifest
# Key changes from apps/v1beta1 to apps/v1:
# - apiVersion: apps/v1 (not apps/v1beta1)
# - selector field is REQUIRED in apps/v1
# - selector.matchLabels MUST match template.metadata.labels

cat > /tmp/legacy-deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-app
  namespace: migration-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: legacy-app
      version: v1
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

# Step 3: Apply the corrected manifest
kubectl apply -f /tmp/legacy-deployment.yaml

# Step 4: Verify
kubectl get deployment legacy-app -n migration-ns
kubectl rollout status deployment/legacy-app -n migration-ns

#===============================================================================
# KEY DIFFERENCES: apps/v1beta1 vs apps/v1 (Professional-Sea4743 pattern)
#===============================================================================
# apps/v1beta1 (DEPRECATED):
#   spec:
#     replicas: 2
#     template:  # No selector required
#       ...
#
# apps/v1 (CURRENT):
#   spec:
#     replicas: 2
#     selector:          # REQUIRED in v1!
#       matchLabels:
#         app: legacy-app
#     template:
#       metadata:
#         labels:        # MUST match selector.matchLabels
#           app: legacy-app
#       ...
#
# Key point: selector.matchLabels MUST match template.metadata.labels
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 45 seconds)
================================================================================
This question gives you a YAML file to fix - just edit it!

Step 1: Open the file (5 sec)
  vi /tmp/legacy-deployment.yaml

Step 2: Make two changes (30 sec)
  - Change: apiVersion: apps/v1beta1 -> apps/v1
  - ADD selector field (REQUIRED for apps/v1!):
    spec:
      selector:
        matchLabels:
          app: legacy-app  # Must match template labels!
  Save (:wq)

Step 3: Apply the fixed file (10 sec)
  kubectl apply -f /tmp/legacy-deployment.yaml

KEY: apps/v1 REQUIRES spec.selector.matchLabels that MUST match
     template.metadata.labels exactly!
================================================================================
'
