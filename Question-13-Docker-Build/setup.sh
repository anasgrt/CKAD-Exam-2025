#!/bin/bash
# Question 13: Docker Build + OCI Export - Setup

set -e
echo "🔧 Setting up Question 13 environment..."

# Check if podman is installed, if not, install it
if ! command -v podman &> /dev/null; then
    echo "📦 Podman not found. Installing podman..."

    # Detect OS and install accordingly
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                apt-get update -qq
                apt-get install -y podman
                ;;
            rhel|centos|fedora)
                yum install -y podman
                ;;
            *)
                echo "⚠️  Unsupported OS. Please install podman manually."
                ;;
        esac
    fi

    # Verify installation
    if command -v podman &> /dev/null; then
        echo "✅ Podman installed successfully: $(podman --version)"
    else
        echo "❌ Failed to install podman. Please install manually."
        if command -v docker &> /dev/null; then
            echo "ℹ️  Docker is available and can be used instead."
        fi
    fi
else
    echo "✅ Podman is already installed: $(podman --version)"
fi

# Also check for docker
if command -v docker &> /dev/null; then
    echo "✅ Docker is also available: $(docker --version)"
fi
echo ""

# Create app directory
mkdir -p /tmp/app

# Create Dockerfile
cat > /tmp/app/Dockerfile <<'EOF'
FROM docker.io/nginx:alpine
LABEL maintainer="exam@ckad.io"
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create index.html
cat > /tmp/app/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>CKAD App</title></head>
<body>
<h1>Welcome to CKAD Exam Practice!</h1>
<p>This is a sample application for container build practice.</p>
</body>
</html>
EOF

# Clean up any previous builds
docker rmi myapp:v1 2>/dev/null || true
podman rmi myapp:v1 2>/dev/null || true
rm -f /tmp/myapp-v1.tar

echo ""
echo "✅ Dockerfile created at /tmp/app/Dockerfile"
echo "✅ index.html created at /tmp/app/index.html"
echo ""
echo "📍 Contents of /tmp/app/Dockerfile:"
echo "----------------------------------------"
cat /tmp/app/Dockerfile
echo ""
echo "----------------------------------------"
echo ""
echo "📍 Your tasks:"
echo "   1. Build image with tag: myapp:v1"
echo "   2. Export to OCI format: /tmp/myapp-v1.tar"
echo ""
echo "🎯 Environment ready!"
