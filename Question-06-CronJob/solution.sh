#!/bin/bash
#===============================================================================
# SOLUTION: Question 6 - CronJob Configuration
#===============================================================================

# Create the CronJob with all specifications
cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: my-cronjob
spec:
  schedule: "*/30 * * * *"
  startingDeadlineSeconds: 17
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      completions: 8
      activeDeadlineSeconds: 8
      template:
        spec:
          containers:
          - name: cronjob-container
            image: busybox
            command: ["/bin/sh", "-c", "date; echo Hello"]
          restartPolicy: OnFailure
EOF

# Verify CronJob was created
kubectl get cronjob my-cronjob

# Create Job manually from CronJob
kubectl create job my-job --from=cronjob/my-cronjob

# Check the job and logs
kubectl get job my-job
kubectl logs -l job-name=my-job

#===============================================================================
# KEY POINTS:
#===============================================================================
# CronJob spec level (spec.):
#   - startingDeadlineSeconds: 17
#   - successfulJobsHistoryLimit: 3
#   - failedJobsHistoryLimit: 1
#
# Job spec level (jobTemplate.spec.):
#   - completions: 8
#   - activeDeadlineSeconds: 8
#
# Pod spec level (template.spec.):
#   - restartPolicy: OnFailure (or Never)
#   - containers with command
#
# Schedule format: */30 * * * * = every 30 minutes
#===============================================================================

: '
================================================================================
⚡ FASTEST EXAM APPROACH (< 90 seconds)
================================================================================
Step 1: Generate CronJob YAML (20 sec)
  kubectl create cronjob my-cronjob --image=busybox \
    --schedule="*/30 * * * *" --dry-run=client -o yaml > cj.yaml

Step 2: Edit cj.yaml to add required fields (50 sec)
  spec:
    startingDeadlineSeconds: 17
    successfulJobsHistoryLimit: 3
    failedJobsHistoryLimit: 1
    jobTemplate:
      spec:
        completions: 8
        activeDeadlineSeconds: 8
        template:
          spec:
            containers:
            - command: ["/bin/sh", "-c", "date; echo Hello"]
  kubectl apply -f cj.yaml

Step 3: Create Job from CronJob (20 sec)
  kubectl create job my-job --from=cronjob/my-cronjob

KEY: startingDeadlineSeconds → CronJob level
     activeDeadlineSeconds → Job level (jobTemplate.spec)
================================================================================
'
