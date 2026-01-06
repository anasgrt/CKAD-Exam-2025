#!/bin/bash
echo "🧹 Cleaning up Question 9..."
kubectl delete pod sidecar-pod --ignore-not-found=true
echo "✅ Cleanup complete!"
