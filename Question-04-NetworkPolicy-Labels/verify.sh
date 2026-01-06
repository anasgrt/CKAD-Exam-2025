#!/bin/bash
# Question 4: NetworkPolicy - Adjust Pod Labels - Verification
# Exam Pattern: api-pod needs tier=api label to match allow-front-to-api and allow-api-to-db policies

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Pod api-pod exists
echo -n "1. Checking pod 'api-pod' exists... "
if kubectl get pod api-pod -n app-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod 'api-pod' not found\n"
    PASS=false
fi

# Check 2: Pod has tier=api label
echo -n "2. Checking api-pod has label 'tier=api'... "
TIER_LABEL=$(kubectl get pod api-pod -n app-ns -o jsonpath='{.metadata.labels.tier}' 2>/dev/null)
if [ "$TIER_LABEL" = "api" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod label 'tier' is '$TIER_LABEL', expected 'api'\n"
    PASS=false
fi

# Check 3: All 4 NetworkPolicies exist (were not modified or deleted)
echo -n "3. Checking all 4 NetworkPolicies still exist... "
NP_COUNT=$(kubectl get networkpolicy -n app-ns --no-headers 2>/dev/null | wc -l)
if [ "$NP_COUNT" -eq "4" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Expected 4 NetworkPolicies, found $NP_COUNT\n"
    PASS=false
fi

# Check 4: allow-front-to-api policy was NOT modified
echo -n "4. Checking 'allow-front-to-api' policy not modified... "
NP_SELECTOR=$(kubectl get networkpolicy allow-front-to-api -n app-ns -o jsonpath='{.spec.podSelector.matchLabels.tier}' 2>/dev/null)
if [ "$NP_SELECTOR" = "api" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - NetworkPolicy 'allow-front-to-api' was modified\n"
    PASS=false
fi

# Check 5: Pod still has original app label
echo -n "5. Checking pod still has 'app=api' label... "
APP_LABEL=$(kubectl get pod api-pod -n app-ns -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
if [ "$APP_LABEL" = "api" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Original 'app' label was removed\n"
    PASS=false
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎉 Great job! You correctly identified that api-pod needed the 'tier=api' label"
    echo "   to match the 'allow-front-to-api' and 'allow-api-to-db' NetworkPolicies."
    echo ""
    echo "   Traffic flow enabled:"
    echo "   front-pod (tier=frontend) --> api-pod (tier=api) --> db-pod (tier=database)"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: Examine the NetworkPolicies with 'kubectl describe networkpolicy -n app-ns'"
    echo "   Look at allow-front-to-api and allow-api-to-db policies."
    echo "   What label does api-pod need to be selected by these policies?"
    exit 1
fi
