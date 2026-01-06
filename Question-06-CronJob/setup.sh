#!/bin/bash
# Question 6: CronJob Configuration - Setup

set -e
echo "🔧 Setting up Question 6 environment..."

# Clean up any existing resources
kubectl delete cronjob my-cronjob --ignore-not-found=true 2>/dev/null || true
kubectl delete job my-job --ignore-not-found=true 2>/dev/null || true
kubectl delete job -l app=my-cronjob --ignore-not-found=true 2>/dev/null || true
sleep 2

echo ""
echo "✅ Environment cleaned"
echo ""
echo "📍 Current CronJobs:"
kubectl get cronjobs 2>/dev/null || echo "   (none)"
echo ""
echo "📍 Current Jobs:"
kubectl get jobs 2>/dev/null || echo "   (none)"
echo ""
echo "🎯 Environment ready!"
