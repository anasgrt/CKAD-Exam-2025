#!/bin/bash
#===============================================================================
# SOLUTION: Question 5 - ResourceQuota and LimitRange Compliance
#===============================================================================

# Step 1: Examine the LimitRange to find the maximum limits
echo "=== Step 1: Check LimitRange ==="
kubectl describe limitrange resource-limits -n limited-ns
# From the LimitRange output (Professional-Sea4743 pattern):
# - Max CPU: 1 (1000m)
# - Max Memory: 640Mi
# Half of max CPU = 500m
# Half of max Memory = 320Mi

# Step 2: Check the ResourceQuota as well
echo ""
echo "=== Step 2: Check ResourceQuota ==="
kubectl describe resourcequota compute-quota -n limited-ns

# Step 3: Create the pod with resource requirements (half of LimitRange max)
echo ""
echo "=== Step 3: Create Pod with half of max limits ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: quota-pod
  namespace: limited-ns
spec:
  containers:
  - name: nginx-container
    image: nginx
    resources:
      requests:
        cpu: "500m"
        memory: "320Mi"
      limits:
        cpu: "500m"
        memory: "320Mi"
EOF

# Verify pod is running
echo ""
echo "=== Verification ==="
kubectl get pod quota-pod -n limited-ns

# Check quota usage
kubectl describe resourcequota compute-quota -n limited-ns

#===============================================================================
# KEY POINTS (Professional-Sea4743 Pattern):
#===============================================================================
# 1. LimitRange defines min/max resource constraints per container
# 2. ResourceQuota defines total namespace resource limits
# 3. When both exist, pods must comply with BOTH constraints
# 4. To find half of max: LimitRange shows max.cpu=1, so half=500m
# 5. To find half of max memory: LimitRange shows max.memory=640Mi, so half=320Mi
# 6. In real exam, use kubectl describe to discover these values
# 7. Both requests and limits are required when quota enforces them
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds)
================================================================================
Step 1: Get the max values from LimitRange (15 sec)
  kubectl describe limitrange -n limited-ns | grep -i max
  # Shows: Max cpu=1, memory=640Mi
  # Calculate half: cpu=500m, memory=320Mi

Step 2: Create pod with calculated values (30 sec)
  kubectl run quota-pod --image=nginx -n limited-ns --dry-run=client -o yaml > pod.yaml
  # Edit pod.yaml to add resources (or use the YAML below)

OR use this one-liner with kubectl run + patch:
  kubectl run quota-pod --image=nginx -n limited-ns \
    --overrides='"'"'{"spec":{"containers":[{"name":"quota-pod","image":"nginx","resources":{"requests":{"cpu":"500m","memory":"320Mi"},"limits":{"cpu":"500m","memory":"320Mi"}}}]}}'"'"'

Step 3: Verify (15 sec)
  kubectl get pod quota-pod -n limited-ns

MATH TIP: Half of 640Mi = 320Mi, Half of 1 (1000m) = 500m
================================================================================
'
