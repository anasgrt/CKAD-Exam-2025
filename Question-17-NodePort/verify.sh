#!/bin/bash
# Question 17: Expose Deployment with NodePort - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Service exists
echo -n "1. Checking service 'frontend-service' exists... "
if kubectl get svc frontend-service -n web-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service 'frontend-service' not found in namespace 'web-ns'\n"
    PASS=false
fi

# Check 2: Service is NodePort type
echo -n "2. Checking service type is 'NodePort'... "
SVC_TYPE=$(kubectl get svc frontend-service -n web-ns -o jsonpath='{.spec.type}' 2>/dev/null)
if [ "$SVC_TYPE" = "NodePort" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service type is '$SVC_TYPE', expected 'NodePort'\n"
    PASS=false
fi

# Check 3: Service port is 80
echo -n "3. Checking service port is 80... "
SVC_PORT=$(kubectl get svc frontend-service -n web-ns -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [ "$SVC_PORT" = "80" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service port is '$SVC_PORT', expected '80'\n"
    PASS=false
fi

# Check 4: Target port is 8080
echo -n "4. Checking target port is 8080... "
TARGET_PORT=$(kubectl get svc frontend-service -n web-ns -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
if [ "$TARGET_PORT" = "8080" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Target port is '$TARGET_PORT', expected '8080'\n"
    PASS=false
fi

# Check 5: NodePort is 30080
echo -n "5. Checking nodePort is 30080... "
NODE_PORT=$(kubectl get svc frontend-service -n web-ns -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
if [ "$NODE_PORT" = "30080" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - NodePort is '$NODE_PORT', expected '30080'\n"
    PASS=false
fi

# Check 6: Service has endpoints
echo -n "6. Checking service has endpoints... "
ENDPOINTS=$(kubectl get endpoints frontend-service -n web-ns -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$ENDPOINTS" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service has no endpoints (selector mismatch?)\n"
    PASS=false
fi

# Check 7: Service selector matches deployment
echo -n "7. Checking service selector matches deployment pods... "
SVC_SELECTOR=$(kubectl get svc frontend-service -n web-ns -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$SVC_SELECTOR" = "frontend-app" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service selector 'app' is '$SVC_SELECTOR', expected 'frontend-app'\n"
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
