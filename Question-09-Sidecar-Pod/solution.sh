#!/bin/bash
#===============================================================================
# SOLUTION: Question 9 - Multi-Container Sidecar Pod
#===============================================================================

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
  namespace: default
spec:
  volumes:
  - name: log-volume
    emptyDir: {}
  initContainers:
  - name: log-sidecar
    image: busybox
    restartPolicy: Always
    command: ["/bin/sh", "-c"]
    args:
    - tail -F /var/log/app.log
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  containers:
  - name: main-app
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
    - while true; do echo $(date) - Log entry >> /var/log/app.log; sleep 5; done
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
EOF

# Verify pod is running
kubectl get pod sidecar-pod

# View logs from sidecar container
kubectl logs sidecar-pod -c log-sidecar --tail=5

# Check log file directly from main container
kubectl exec sidecar-pod -c main-app -- cat /var/log/app.log

#===============================================================================
# KEY POINTS (Native Sidecar Pattern - Kubernetes 1.29+):
#===============================================================================
# 1. Native sidecars are defined in initContainers with restartPolicy: Always
# 2. They start before main containers and run throughout Pod lifecycle
# 3. emptyDir volume is created when pod starts, deleted when pod terminates
# 4. All containers in a pod can share volumes by mounting the same volume
# 5. volumeMounts.name must match volumes.name
# 6. Use -c <container-name> to specify container for logs/exec
# 7. tail -F (capital F) follows by filename, survives log rotation
# 8. Sidecar containers terminate AFTER main containers on Pod shutdown
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
NO IMPERATIVE SHORTCUT - YAML required for sidecar pattern!

Step 1: Generate base pod YAML (15 sec)
  kubectl run sidecar-pod --image=busybox --dry-run=client -o yaml > pod.yaml

Step 2: Edit pod.yaml (60 sec) - add:
  - volumes: [{name: log-volume, emptyDir: {}}]
  - initContainers (NATIVE SIDECAR with restartPolicy: Always)
  - volumeMounts on both containers

Step 3: Apply and verify (15 sec)
  kubectl apply -f pod.yaml
  kubectl logs sidecar-pod -c log-sidecar --tail=5

K8s 1.29+ NATIVE SIDECAR PATTERN:
  Sidecar goes in initContainers with restartPolicy: Always
  This ensures sidecar starts FIRST and stays running!
================================================================================
'
