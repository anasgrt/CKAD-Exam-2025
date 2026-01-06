#!/bin/bash
# Question 8: Canary Deployment - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Canary deployment exists
echo -n "1. Checking deployment 'web-app-canary' exists... "
if kubectl get deployment web-app-canary -n canary-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'web-app-canary' not found\n"
    PASS=false
fi

# Check 2: Canary has 1 replica
echo -n "2. Checking canary deployment has 1 replica... "
REPLICAS=$(kubectl get deployment web-app-canary -n canary-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "1" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Canary has '$REPLICAS' replicas, expected '1'\n"
    PASS=false
fi

# Check 3: Canary uses nginx:1.20 image
echo -n "3. Checking canary uses image 'nginx:1.20'... "
IMAGE=$(kubectl get deployment web-app-canary -n canary-ns -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" = "nginx:1.20" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Canary image is '$IMAGE', expected 'nginx:1.20'\n"
    PASS=false
fi

# Check 4: Canary pods have app=web-app label
echo -n "4. Checking canary pods have 'app=web-app' label... "
APP_LABEL=$(kubectl get deployment web-app-canary -n canary-ns -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
if [ "$APP_LABEL" = "web-app" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Canary pod label 'app' is '$APP_LABEL', expected 'web-app'\n"
    PASS=false
fi

# Check 5: Canary pods have version=canary label
echo -n "5. Checking canary pods have 'version=canary' label... "
VERSION_LABEL=$(kubectl get deployment web-app-canary -n canary-ns -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
if [ "$VERSION_LABEL" = "canary" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Canary pod label 'version' is '$VERSION_LABEL', expected 'canary'\n"
    PASS=false
fi

# Check 6: Service has 5 endpoints (4 stable + 1 canary)
echo -n "6. Checking service has 5 endpoints (4 stable + 1 canary)... "
sleep 2
ENDPOINT_COUNT=$(kubectl get endpoints web-service -n canary-ns -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l)
if [ "$ENDPOINT_COUNT" -ge 5 ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service has '$ENDPOINT_COUNT' endpoints, expected 5\n"
    PASS=false
fi

# Check 7: Stable deployment reduced to 4 replicas (Professional-Sea4743: 5->4 stable, add 1 canary for 20%)
echo -n "7. Checking stable deployment 'web-app' has 4 replicas after canary... "
STABLE_REPLICAS=$(kubectl get deployment web-app -n canary-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$STABLE_REPLICAS" = "4" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Stable deployment has '$STABLE_REPLICAS' replicas, expected '4' (reduced from 5)\n"
    PASS=false
fi

# Check 8: Total pods = 5 (within 10 pod limit)
echo -n "8. Checking total pods is 5 (within 10 pod limit)... "
TOTAL_PODS=$(kubectl get pods -n canary-ns -l app=web-app --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$TOTAL_PODS" = "5" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Total pods is '$TOTAL_PODS', expected '5' (4 stable + 1 canary)\n"
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
