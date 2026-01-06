#!/bin/bash
# Question 15: Find Existing ServiceAccount and Apply to Deployment - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking Deployment 'scraper-app' exists... "
if kubectl get deployment scraper-app -n rbac-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'scraper-app' not found in namespace 'rbac-ns'\n"
    PASS=false
fi

# Check 2: Deployment uses correct ServiceAccount (scraper-sa)
echo -n "2. Checking Deployment uses 'scraper-sa' ServiceAccount... "
DEPLOY_SA=$(kubectl get deployment scraper-app -n rbac-ns -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
if [ "$DEPLOY_SA" = "scraper-sa" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment uses ServiceAccount '$DEPLOY_SA', expected 'scraper-sa'\n"
    PASS=false
fi

# Check 3: Pod uses correct ServiceAccount
echo -n "3. Checking Pod uses 'scraper-sa' ServiceAccount... "
POD_SA=$(kubectl get pod -n rbac-ns -l app=scraper -o jsonpath='{.items[0].spec.serviceAccountName}' 2>/dev/null)
if [ "$POD_SA" = "scraper-sa" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod uses ServiceAccount '$POD_SA', expected 'scraper-sa'\n"
    PASS=false
fi

# Check 4: ServiceAccount can list pods
echo -n "4. Checking ServiceAccount can list pods... "
CAN_LIST=$(kubectl auth can-i list pods --as=system:serviceaccount:rbac-ns:scraper-sa -n rbac-ns 2>/dev/null)
if [ "$CAN_LIST" = "yes" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - ServiceAccount 'scraper-sa' cannot list pods\n"
    PASS=false
fi

# Check 5: No new RBAC resources created (should use existing)
echo -n "5. Checking only existing RBAC resources used... "
ROLE_COUNT=$(kubectl get role -n rbac-ns --no-headers 2>/dev/null | wc -l)
BINDING_COUNT=$(kubectl get rolebinding -n rbac-ns --no-headers 2>/dev/null | wc -l)
if [ "$ROLE_COUNT" -eq 1 ] && [ "$BINDING_COUNT" -eq 1 ]; then
    echo "✅ PASS (Using existing RBAC)"
else
    echo "⚠️ WARNING - Extra RBAC resources may have been created"
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎯 You correctly identified 'scraper-sa' as the existing ServiceAccount"
    echo "   with pod list permissions and applied it to the Deployment!"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: Check the RoleBinding to find which SA has permissions:"
    echo "   kubectl get rolebinding pod-list-binding -n rbac-ns -o yaml"
    exit 1
fi
