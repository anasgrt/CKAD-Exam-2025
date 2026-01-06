#!/bin/bash
# Question 20: Pod with Command - Setup

set -e
echo "🔧 Setting up Question 20 environment..."

# Create namespace
kubectl create namespace cmd-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete pod simple-pod -n cmd-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

echo ""
echo "✅ Namespace 'cmd-ns' created"
echo ""
echo "📍 Your task:"
echo "   Create a Pod 'simple-pod' with:"
echo "   - Image: busybox:1.35"
echo "   - Command: sleep 3600"
echo ""
echo "🎯 Environment ready!"
