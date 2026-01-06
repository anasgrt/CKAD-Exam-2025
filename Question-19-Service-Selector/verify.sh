#!/bin/bash
# Question 19: Service Selector Fix - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Service exists
echo -n "1. Checking service 'frontend-svc' exists... "
if kubectl get svc frontend-svc -n svc-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service 'frontend-svc' not found in namespace 'svc-ns'\n"
    PASS=false
fi

# Check 2: Service selector matches pod labels (app=frontend)
echo -n "2. Checking service selector has 'app=frontend'... "
SELECTOR_APP=$(kubectl get svc frontend-svc -n svc-ns -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$SELECTOR_APP" = "frontend" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service selector app='$SELECTOR_APP', expected 'frontend'\n"
    PASS=false
fi

# Check 3: Service selector matches pod labels (tier=web)
echo -n "3. Checking service selector has 'tier=web'... "
SELECTOR_TIER=$(kubectl get svc frontend-svc -n svc-ns -o jsonpath='{.spec.selector.tier}' 2>/dev/null)
if [ "$SELECTOR_TIER" = "web" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service selector tier='$SELECTOR_TIER', expected 'web'\n"
    PASS=false
fi

# Check 4: Endpoints exist
echo -n "4. Checking service has endpoints... "
ENDPOINTS=$(kubectl get endpoints frontend-svc -n svc-ns -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$ENDPOINTS" ] && [ "$ENDPOINTS" != "[]" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Service has no endpoints\n"
    PASS=false
fi

# Check 5: Number of endpoints matches replica count
echo -n "5. Checking endpoint count matches replicas... "
ENDPOINT_COUNT=$(kubectl get endpoints frontend-svc -n svc-ns -o jsonpath='{.subsets[0].addresses}' 2>/dev/null | grep -o '"ip"' | wc -l)
REPLICA_COUNT=$(kubectl get deployment frontend-app -n svc-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$ENDPOINT_COUNT" = "$REPLICA_COUNT" ]; then
    echo "✅ PASS (endpoints: $ENDPOINT_COUNT)"
else
    echo "❌ FAIL"
    ERRORS+="   - Endpoint count: '$ENDPOINT_COUNT', Expected: '$REPLICA_COUNT'\n"
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
