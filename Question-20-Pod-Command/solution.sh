#!/bin/bash
#===============================================================================
# SOLUTION: Question 20 - Pod with Command
#===============================================================================

# Method 1: Using kubectl run (fastest for exam)
kubectl run simple-pod --image=busybox:1.35 -n cmd-ns --command -- sleep 3600

# Method 2: Using YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  namespace: cmd-ns
spec:
  containers:
  - name: busybox
    image: busybox:1.35
    command: ["sleep", "3600"]
EOF

# Method 3: Using command and args separately
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  namespace: cmd-ns
spec:
  containers:
  - name: busybox
    image: busybox:1.35
    command: ["sleep"]
    args: ["3600"]
EOF

# Method 4: Using shell form
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  namespace: cmd-ns
spec:
  containers:
  - name: busybox
    image: busybox:1.35
    command: ["/bin/sh", "-c", "sleep 3600"]
EOF

# Verify
kubectl get pod simple-pod -n cmd-ns
kubectl describe pod simple-pod -n cmd-ns | grep -A5 "Command"

#===============================================================================
# COMMAND vs ARGS:
#===============================================================================
# In Kubernetes:
#   command = Docker ENTRYPOINT (overrides it)
#   args = Docker CMD (overrides it)
#
# If you only specify args, they are passed to the container's ENTRYPOINT
# If you specify command, it replaces ENTRYPOINT completely
#
# Best practice for busybox: use command since it has no default ENTRYPOINT
#===============================================================================

#===============================================================================
# KUBECTL RUN FLAGS:
#===============================================================================
# --command : Use command array instead of args
# --restart=Never : Create a Pod (not a Deployment)
# --image : Container image
# -n : Namespace
# --dry-run=client -o yaml : Generate YAML without creating
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 15 seconds!)
================================================================================
ONE COMMAND - that is it!

  kubectl run simple-pod --image=busybox:1.35 -n cmd-ns --command -- sleep 3600

Verify:
  kubectl get pod simple-pod -n cmd-ns

CRITICAL: --command flag MUST come BEFORE the -- separator!
  --command means "use command array, not args"
  -- separates kubectl flags from the actual command

Without --command, "sleep 3600" would be passed as args
to the container ENTRYPOINT (which busybox does not have)
================================================================================
'
