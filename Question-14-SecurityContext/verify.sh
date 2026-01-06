#!/bin/bash
# Question 14: SecurityContext - Edit Existing Deployment - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking deployment 'secure-app' exists... "
if kubectl get deployment secure-app -n secure-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'secure-app' not found in namespace 'secure-ns'\n"
    PASS=false
fi

# Check 2: Deployment is NOT paused (rollout was resumed)
echo -n "2. Checking deployment is not paused (rollout resumed)... "
PAUSED=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.paused}' 2>/dev/null)
if [ "$PAUSED" != "true" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment is still paused, use 'kubectl rollout resume'\n"
    PASS=false
fi

# Check 3: Pod-level runAsUser is 10000 (Professional-Sea4743 pattern)
echo -n "3. Checking pod runAsUser=10000... "
RUN_AS_USER=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.securityContext.runAsUser}' 2>/dev/null)
if [ "$RUN_AS_USER" = "10000" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod runAsUser is '$RUN_AS_USER', expected '10000'\n"
    PASS=false
fi

# Check 4: Container-level securityContext (capabilities)
echo -n "4. Checking container capabilities add NET_BIND_SERVICE... "
ADD_CAPS=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.containers[0].securityContext.capabilities.add}' 2>/dev/null)
if [[ "$ADD_CAPS" == *"NET_BIND_SERVICE"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Capabilities add: '$ADD_CAPS', expected to include 'NET_BIND_SERVICE'\n"
    PASS=false
fi

# Check 5: allowPrivilegeEscalation is false
echo -n "5. Checking container allowPrivilegeEscalation=false... "
ALLOW_PE=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [ "$ALLOW_PE" = "false" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - allowPrivilegeEscalation is '$ALLOW_PE', expected 'false'\n"
    PASS=false
fi

# Check 6: Deployment rollout completed
echo -n "6. Checking deployment rollout completed... "
AVAILABLE=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$AVAILABLE" = "$DESIRED" ] && [ -n "$AVAILABLE" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Rollout not complete (available: $AVAILABLE, desired: $DESIRED)\n"
    PASS=false
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎉 Excellent! You successfully:"
    echo "   - Added Pod-level securityContext (runAsUser: 10000)"
    echo "   - Added Container-level securityContext (capabilities: NET_BIND_SERVICE)"
    echo "   - Resumed the paused deployment rollout"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: Use 'kubectl edit deployment secure-app -n secure-ns' to add securityContext"
    echo "   Then 'kubectl rollout resume deployment/secure-app -n secure-ns' to resume"
    exit 1
fi
