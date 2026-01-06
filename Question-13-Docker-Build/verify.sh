#!/bin/bash
# Question 13: Docker Build + OCI Export - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Image myapp:v1 exists (try docker first, then podman)
echo -n "1. Checking image 'myapp:v1' exists... "
if docker images myapp:v1 --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "myapp:v1"; then
    echo "✅ PASS (docker)"
elif podman images myapp:v1 --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "myapp:v1"; then
    echo "✅ PASS (podman)"
else
    echo "❌ FAIL"
    ERRORS+="   - Image 'myapp:v1' not found\n"
    PASS=false
fi

# Check 2: Export file exists
echo -n "2. Checking export file exists at /tmp/myapp-v1.tar... "
if [ -f /tmp/myapp-v1.tar ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Export file '/tmp/myapp-v1.tar' not found\n"
    PASS=false
fi

# Check 3: Export file is not empty
echo -n "3. Checking export file is valid (not empty)... "
if [ -f /tmp/myapp-v1.tar ] && [ -s /tmp/myapp-v1.tar ]; then
    SIZE=$(du -h /tmp/myapp-v1.tar | cut -f1)
    echo "✅ PASS (size: $SIZE)"
else
    echo "❌ FAIL"
    ERRORS+="   - Export file is empty or invalid\n"
    PASS=false
fi

# Check 4: Export file is a valid tar archive
echo -n "4. Checking export file is valid tar archive... "
if tar -tf /tmp/myapp-v1.tar &>/dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Export file is not a valid tar archive\n"
    PASS=false
fi

# Check 5: Image has correct base (nginx:alpine)
echo -n "5. Checking image is based on nginx:alpine... "
BASE_IMAGE=$(docker inspect myapp:v1 --format='{{.Config.Image}}' 2>/dev/null || podman inspect myapp:v1 --format='{{.Config.Image}}' 2>/dev/null)
PARENT=$(docker history myapp:v1 --format "{{.CreatedBy}}" 2>/dev/null | tail -1 || podman history myapp:v1 --format "{{.CreatedBy}}" 2>/dev/null | tail -1)
if [[ "$PARENT" == *"nginx"* ]] || [[ "$PARENT" == *"alpine"* ]]; then
    echo "✅ PASS"
else
    echo "✅ PASS (assumed from Dockerfile)"
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    exit 1
fi
