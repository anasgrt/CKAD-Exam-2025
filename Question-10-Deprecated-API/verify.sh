#!/bin/bash
# Question 10: Fix Deprecated API Version - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking deployment 'legacy-app' exists... "
if kubectl get deployment legacy-app -n migration-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'legacy-app' not found in namespace 'migration-ns'\n"
    PASS=false
fi

# Check 2: API version is apps/v1 (not apps/v1beta1)
echo -n "2. Checking API version is apps/v1... "
API_VERSION=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.apiVersion}' 2>/dev/null)
if [ "$API_VERSION" = "apps/v1" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - API version is '$API_VERSION', expected 'apps/v1'\n"
    PASS=false
fi

# Check 3: Selector field exists (required in apps/v1)
echo -n "3. Checking selector field exists... "
SELECTOR=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.spec.selector.matchLabels}' 2>/dev/null)
if [ -n "$SELECTOR" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Selector field not found (required in apps/v1)\n"
    PASS=false
fi

# Check 4: Selector matchLabels contains app=legacy-app
echo -n "4. Checking selector has app=legacy-app... "
APP_LABEL=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
if [ "$APP_LABEL" = "legacy-app" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Selector app label is '$APP_LABEL', expected 'legacy-app'\n"
    PASS=false
fi

# Check 5: Template labels match selector
echo -n "5. Checking template labels match selector... "
TEMPLATE_APP=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
if [ "$TEMPLATE_APP" = "$APP_LABEL" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Template labels don't match selector (selector: $APP_LABEL, template: $TEMPLATE_APP)\n"
    PASS=false
fi

# Check 6: Replicas is 2
echo -n "6. Checking replicas is 2... "
REPLICAS=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" = "2" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Replicas is '$REPLICAS', expected '2'\n"
    PASS=false
fi

# Check 7: Deployment rollout completed
echo -n "7. Checking deployment rollout completed... "
AVAILABLE=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.status.availableReplicas}' 2>/dev/null)
DESIRED=$(kubectl get deployment legacy-app -n migration-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
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
    echo "   - Updated apiVersion from apps/v1beta1 to apps/v1"
    echo "   - Added the required selector field"
    echo "   - Ensured selector.matchLabels matches template.metadata.labels"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: In apps/v1, selector field is REQUIRED"
    echo "   selector.matchLabels MUST match template.metadata.labels"
    exit 1
fi
