#!/bin/bash
# Question 12: Job with Failure Policy - Setup

set -e
echo "🔧 Setting up Question 12 environment..."

# Create namespace
kubectl create namespace job-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete job backup-job -n job-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

echo ""
echo "✅ Namespace 'job-ns' created"
echo ""
echo "📍 Your task:"
echo "   Create a Job named 'backup-job' with:"
echo "   - backoffLimit: 3"
echo "   - activeDeadlineSeconds: 60"
echo ""
echo "🎯 Environment ready!"
