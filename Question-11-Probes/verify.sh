#!/bin/bash
# Question 11: Modify Deployment Twice, Then Rollback - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking deployment 'web-app' exists... "
if kubectl get deployment web-app -n health-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'web-app' not found in namespace 'health-ns'\n"
    PASS=false
fi

# Check 2: Readiness probe exists (should remain after rollback)
echo -n "2. Checking readiness probe exists... "
READINESS_PROBE=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)
if [ -n "$READINESS_PROBE" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Readiness probe not found on container\n"
    PASS=false
fi

# Check 3: Readiness probe path is /healthz
echo -n "3. Checking readiness probe path=/healthz... "
READINESS_PATH=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [ "$READINESS_PATH" = "/healthz" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Readiness probe path is '$READINESS_PATH', expected '/healthz'\n"
    PASS=false
fi

# Check 4: Readiness probe port is 8080
echo -n "4. Checking readiness probe port=8080... "
READINESS_PORT=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)
if [ "$READINESS_PORT" = "8080" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Readiness probe port is '$READINESS_PORT', expected '8080'\n"
    PASS=false
fi

# Check 5: Image is nginx:1.21 (rolled back from nginx:1.22)
echo -n "5. Checking image is nginx:1.21 (after rollback)... "
IMAGE=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "nginx:1.21" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'nginx:1.21' after rollback\n"
    PASS=false
fi

# Check 6: Multiple revisions exist in history (proves modifications were made)
echo -n "6. Checking rollout history has multiple revisions... "
REVISIONS=$(kubectl rollout history deployment/web-app -n health-ns 2>/dev/null | grep -c "^[0-9]")
if [ "$REVISIONS" -ge 2 ]; then
    echo "✅ PASS (Found $REVISIONS revisions)"
else
    echo "❌ FAIL"
    ERRORS+="   - Not enough revision history. Need at least 2 modifications.\n"
    PASS=false
fi

# Check 7: Deployment has completed rollout
echo -n "7. Checking deployment rollout completed... "
AVAILABLE=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deployment web-app -n health-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$AVAILABLE" = "$DESIRED" ] && [ -n "$AVAILABLE" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment rollout not complete (available: $AVAILABLE, desired: $DESIRED)\n"
    PASS=false
fi

# Check 8: Pods are Running and Ready
echo -n "8. Checking pods are Running and Ready... "
READY_PODS=$(kubectl get pods -n health-ns -l app=web-app -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
if [[ "$READY_PODS" == *"True"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pods are not Ready\n"
    PASS=false
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎉 Excellent! You successfully:"
    echo "   1. Added readiness probe (first modification)"
    echo "   2. Changed image to nginx:1.22 (second modification)"
    echo "   3. Rolled back to previous revision (nginx:1.21 with probe)"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hints:"
    echo "   - First modification: Add readiness probe"
    echo "   - Second modification: kubectl set image deployment/web-app nginx=nginx:1.22 -n health-ns"
    echo "   - Rollback: kubectl rollout undo deployment/web-app -n health-ns"
    exit 1
fi
