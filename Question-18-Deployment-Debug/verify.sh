#!/bin/bash
# Question 18: Fix Deployment - Container Name & Image + Resume - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking deployment 'api-server' exists... "
if kubectl get deployment api-server -n api-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'api-server' not found\n"
    PASS=false
fi

# Check 2: Deployment is NOT paused (rollout was resumed)
echo -n "2. Checking deployment is not paused (rollout resumed)... "
PAUSED=$(kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.paused}' 2>/dev/null)
if [ "$PAUSED" != "true" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment is still paused, use 'kubectl rollout resume'\n"
    PASS=false
fi

# Check 3: Container name is 'api-container'
echo -n "3. Checking container name is 'api-container'... "
CONTAINER_NAME=$(kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.template.spec.containers[0].name}' 2>/dev/null)
if [ "$CONTAINER_NAME" = "api-container" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Container name is '$CONTAINER_NAME', expected 'api-container'\n"
    PASS=false
fi

# Check 4: Image is 'nginx:1.21'
echo -n "4. Checking image is 'nginx:1.21'... "
IMAGE=$(kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "nginx:1.21" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'nginx:1.21'\n"
    PASS=false
fi

# Check 5: Deployment rollout completed
echo -n "5. Checking deployment rollout completed... "
AVAILABLE=$(kubectl get deployment api-server -n api-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deployment api-server -n api-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$AVAILABLE" = "$DESIRED" ] && [ -n "$AVAILABLE" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Rollout not complete (available: $AVAILABLE, desired: $DESIRED)\n"
    PASS=false
fi

# Check 6: Pods are Running
echo -n "6. Checking pods are Running... "
RUNNING_PODS=$(kubectl get pods -n api-ns -l app=api-server --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$RUNNING_PODS" -ge 1 ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - No running pods found\n"
    PASS=false
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎉 Excellent! You successfully:"
    echo "   - Changed container name from 'wrong-name' to 'api-container'"
    echo "   - Changed image from 'nginx:wrong' to 'nginx:1.21'"
    echo "   - Resumed the paused deployment rollout"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: Use 'kubectl edit deployment api-server -n api-ns' to fix issues"
    echo "   Then 'kubectl rollout resume deployment/api-server -n api-ns' to resume"
    exit 1
fi
