#!/bin/bash
# Question 2: Fix Broken Ingress - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Ingress exists
echo -n "1. Checking Ingress 'web-ingress' exists... "
if kubectl get ingress web-ingress -n production &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Ingress 'web-ingress' not found\n"
    PASS=false
fi

# Check 2: Host is correct (app.example.com, not app.exmple.com)
echo -n "2. Checking host is 'app.example.com'... "
HOST=$(kubectl get ingress web-ingress -n production -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$HOST" = "app.example.com" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Host is '$HOST', expected 'app.example.com'\n"
    PASS=false
fi

# Check 3: Backend service name is correct (web-service, not web-svc)
echo -n "3. Checking backend service is 'web-service'... "
SVC_NAME=$(kubectl get ingress web-ingress -n production -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$SVC_NAME" = "web-service" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Backend service is '$SVC_NAME', expected 'web-service'\n"
    PASS=false
fi

# Check 4: Backend port is correct (80, not 8080)
echo -n "4. Checking backend port is 80... "
SVC_PORT=$(kubectl get ingress web-ingress -n production -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
if [ "$SVC_PORT" = "80" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Backend port is '$SVC_PORT', expected '80'\n"
    PASS=false
fi

# Check 5: Service has endpoints (connectivity check)
echo -n "5. Checking service has endpoints... "
ENDPOINTS=$(kubectl get endpoints web-service -n production -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$ENDPOINTS" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service 'web-service' has no endpoints\n"
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
