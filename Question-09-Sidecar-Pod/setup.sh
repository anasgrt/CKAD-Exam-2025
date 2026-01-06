#!/bin/bash
# Question 9: Multi-Container Sidecar Pod - Setup

set -e
echo "🔧 Setting up Question 9 environment..."

# Clean up
kubectl delete pod sidecar-pod --ignore-not-found=true 2>/dev/null || true
sleep 2

echo ""
echo "✅ Environment cleaned"
echo ""
echo "📍 Current pods in default namespace:"
kubectl get pods 2>/dev/null || echo "   (none)"
echo ""
echo "🎯 Environment ready!"
