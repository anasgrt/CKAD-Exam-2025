#!/bin/bash
#===============================================================================
# SOLUTION: Question 12 - Job with Failure Policy
#===============================================================================

# Method 1: Using YAML manifest
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
  namespace: job-ns
spec:
  backoffLimit: 3
  activeDeadlineSeconds: 60
  template:
    spec:
      containers:
      - name: backup
        image: busybox:1.35
        command:
        - sh
        - -c
        - "echo Starting backup && sleep 5 && echo Backup complete"
      restartPolicy: Never
EOF

# Monitor job
kubectl get job backup-job -n job-ns -w

# Check job status
kubectl describe job backup-job -n job-ns

# View logs
kubectl logs job/backup-job -n job-ns

#===============================================================================
# METHOD 2: Using kubectl create
#===============================================================================
# kubectl create job backup-job --image=busybox:1.35 -n job-ns --dry-run=client -o yaml -- sh -c "echo Starting backup && sleep 5 && echo Backup complete" > job.yaml
# Then edit job.yaml to add backoffLimit and activeDeadlineSeconds
# kubectl apply -f job.yaml

#===============================================================================
# KEY POINTS - JOB PARAMETERS:
#===============================================================================
# backoffLimit: Number of retries before considering job as failed (default 6)
# activeDeadlineSeconds: Max duration for job (terminates if exceeded)
# completions: Number of successful pod completions needed (default 1)
# parallelism: Number of pods that can run in parallel (default 1)
# ttlSecondsAfterFinished: Auto-cleanup after job completes
#
# restartPolicy for Jobs: Must be "Never" or "OnFailure" (not "Always")
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 60 seconds)
================================================================================
Step 1: Generate Job YAML (15 sec)
  kubectl create job backup-job --image=busybox:1.35 -n job-ns \
    --dry-run=client -o yaml -- sh -c "echo Backup done" > job.yaml

Step 2: Edit job.yaml to add required fields (30 sec)
  vi job.yaml
  # Add at spec level (above template):
  #   backoffLimit: 3
  #   activeDeadlineSeconds: 60
  kubectl apply -f job.yaml

Step 3: Verify (15 sec)
  kubectl get job backup-job -n job-ns
  kubectl logs job/backup-job -n job-ns

TIP: backoffLimit and activeDeadlineSeconds go at spec level,
     NOT inside template!
================================================================================
'
