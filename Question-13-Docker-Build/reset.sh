#!/bin/bash
echo "🧹 Cleaning up Question 13..."
docker rmi myapp:v1 2>/dev/null || true
podman rmi myapp:v1 2>/dev/null || true
rm -f /tmp/myapp-v1.tar
rm -rf /tmp/app
echo "✅ Cleanup complete!"
