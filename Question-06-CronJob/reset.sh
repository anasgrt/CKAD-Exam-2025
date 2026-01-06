#!/bin/bash
echo "🧹 Cleaning up Question 6..."
kubectl delete cronjob my-cronjob --ignore-not-found=true
kubectl delete job my-job --ignore-not-found=true
kubectl delete job -l app=my-cronjob --ignore-not-found=true 2>/dev/null || true
echo "✅ Cleanup complete!"
