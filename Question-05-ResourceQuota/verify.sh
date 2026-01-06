#!/bin/bash
# Question 5: ResourceQuota and LimitRange Compliance - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Pod exists
echo -n "1. Checking pod 'quota-pod' exists... "
if kubectl get pod quota-pod -n limited-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod 'quota-pod' not found in namespace 'limited-ns'\n"
    PASS=false
fi

# Check 2: Pod is running
echo -n "2. Checking pod is running... "
STATUS=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$STATUS" = "Running" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod status is '$STATUS', expected 'Running'\n"
    PASS=false
fi

# Check 3: Container name is correct
echo -n "3. Checking container name is 'nginx-container'... "
CONTAINER_NAME=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].name}' 2>/dev/null)
if [ "$CONTAINER_NAME" = "nginx-container" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Container name is '$CONTAINER_NAME', expected 'nginx-container'\n"
    PASS=false
fi

# Check 4: Image is nginx
echo -n "4. Checking image is 'nginx'... "
IMAGE=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == nginx* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'nginx'\n"
    PASS=false
fi

# Check 5: CPU request is 500m (half of max 1000m from LimitRange)
echo -n "5. Checking CPU request is '500m' (half of LimitRange max)... "
CPU_REQ=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
if [ "$CPU_REQ" = "500m" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - CPU request is '$CPU_REQ', expected '500m' (half of LimitRange max cpu=1)\n"
    PASS=false
fi

# Check 6: Memory request is 320Mi (half of max 640Mi from LimitRange) - Professional-Sea4743 pattern
echo -n "6. Checking memory request is '320Mi' (half of LimitRange max)... "
MEM_REQ=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [ "$MEM_REQ" = "320Mi" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Memory request is '$MEM_REQ', expected '320Mi' (half of LimitRange max memory=640Mi)\n"
    PASS=false
fi

# Check 7: CPU limit is 500m (half of max 1000m from LimitRange)
echo -n "7. Checking CPU limit is '500m' (half of LimitRange max)... "
CPU_LIM=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [ "$CPU_LIM" = "500m" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - CPU limit is '$CPU_LIM', expected '500m' (half of LimitRange max cpu=1)\n"
    PASS=false
fi

# Check 8: Memory limit is 320Mi (half of max 640Mi from LimitRange) - Professional-Sea4743 pattern
echo -n "8. Checking memory limit is '320Mi' (half of LimitRange max)... "
MEM_LIM=$(kubectl get pod quota-pod -n limited-ns -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [ "$MEM_LIM" = "320Mi" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Memory limit is '$MEM_LIM', expected '320Mi' (half of LimitRange max memory=640Mi)\n"
    PASS=false
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
