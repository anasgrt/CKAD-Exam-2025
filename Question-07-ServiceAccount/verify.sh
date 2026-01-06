#!/bin/bash
# Question 7: RBAC - ServiceAccount, Role, and RoleBinding - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: ServiceAccount was created
echo -n "1. Checking ServiceAccount 'pod-reader-sa' was created... "
if kubectl get serviceaccount pod-reader-sa -n secure-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - ServiceAccount 'pod-reader-sa' not found\n"
    PASS=false
fi

# Check 2: Role was created with correct name
echo -n "2. Checking Role 'pod-reader-role' was created... "
if kubectl get role pod-reader-role -n secure-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Role 'pod-reader-role' not found\n"
    PASS=false
fi

# Check 3: Role has correct permissions (get, list, watch on pods)
echo -n "3. Checking Role has correct permissions... "
ROLE_VERBS=$(kubectl get role pod-reader-role -n secure-ns -o jsonpath='{.rules[0].verbs[*]}' 2>/dev/null)
ROLE_RESOURCES=$(kubectl get role pod-reader-role -n secure-ns -o jsonpath='{.rules[0].resources[*]}' 2>/dev/null)
if [[ "$ROLE_VERBS" == *"list"* ]] && [[ "$ROLE_RESOURCES" == *"pods"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Role does not have correct permissions (need get,list,watch on pods)\n"
    PASS=false
fi

# Check 4: RoleBinding was created
echo -n "4. Checking RoleBinding 'pod-reader-binding' was created... "
if kubectl get rolebinding pod-reader-binding -n secure-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - RoleBinding 'pod-reader-binding' not found\n"
    PASS=false
fi

# Check 5: RoleBinding references correct Role and ServiceAccount
echo -n "5. Checking RoleBinding references correct Role and SA... "
RB_ROLE=$(kubectl get rolebinding pod-reader-binding -n secure-ns -o jsonpath='{.roleRef.name}' 2>/dev/null)
RB_SA=$(kubectl get rolebinding pod-reader-binding -n secure-ns -o jsonpath='{.subjects[0].name}' 2>/dev/null)
if [ "$RB_ROLE" = "pod-reader-role" ] && [ "$RB_SA" = "pod-reader-sa" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - RoleBinding does not reference correct Role or SA\n"
    PASS=false
fi

# Check 6: Deployment uses pod-reader-sa ServiceAccount
echo -n "6. Checking deployment uses 'pod-reader-sa' ServiceAccount... "
SA_NAME=$(kubectl get deployment secure-app -n secure-ns -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null)
if [ "$SA_NAME" = "pod-reader-sa" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - ServiceAccountName is '$SA_NAME', expected 'pod-reader-sa'\n"
    PASS=false
fi

# Check 7: Deployment exists and pods are running
echo -n "7. Checking deployment pods are running... "
sleep 2
RUNNING_PODS=$(kubectl get pods -n secure-ns -l app=secure-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$RUNNING_PODS" -ge 1 ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - No running pods found\n"
    PASS=false
fi

# Check 8: Permission verification using auth can-i
echo -n "8. Verifying pod-reader-sa can list pods... "
CAN_LIST=$(kubectl auth can-i list pods -n secure-ns --as=system:serviceaccount:secure-ns:pod-reader-sa 2>/dev/null)
if [ "$CAN_LIST" = "yes" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - ServiceAccount cannot list pods (check Role and RoleBinding)\n"
    PASS=false
fi

echo ""

if [ "$PASS" = true ]; then
    echo "📊 Result: All checks passed!"
    echo ""
    echo "🎉 Excellent! You successfully created the full RBAC chain:"
    echo "   ServiceAccount → Role → RoleBinding → Deployment"
    exit 0
else
    echo "📊 Result: Some checks failed"
    echo ""
    echo "Errors:"
    echo -e "$ERRORS"
    echo ""
    echo "💡 Hint: Create SA, Role, RoleBinding, then update the deployment"
    exit 1
fi
