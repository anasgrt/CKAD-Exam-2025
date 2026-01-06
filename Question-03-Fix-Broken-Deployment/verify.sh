#!/bin/bash
# Question 3: Fix Broken Deployment - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Deployment exists
echo -n "1. Checking Deployment 'backend-deployment' exists... "
if kubectl get deployment backend-deployment -n staging &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'backend-deployment' not found\n"
    PASS=false
fi

# Check 2: Deployment references correct secret
echo -n "2. Checking deployment references 'db-credentials' secret... "
SECRET_REF=$(kubectl get deployment backend-deployment -n staging -o jsonpath='{.spec.template.spec.containers[0].envFrom[0].secretRef.name}' 2>/dev/null)
if [ "$SECRET_REF" = "db-credentials" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Secret reference is '$SECRET_REF', expected 'db-credentials'\n"
    PASS=false
fi

# Check 3: Pods are running
echo -n "3. Checking pods are running... "
sleep 2
RUNNING_PODS=$(kubectl get pods -n staging -l app=backend --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
if [ "$RUNNING_PODS" -ge 1 ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    POD_STATUS=$(kubectl get pods -n staging -l app=backend -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    ERRORS+="   - No running pods found (status: $POD_STATUS)\n"
    PASS=false
fi

# Check 4: Pod has environment variables from secret
echo -n "4. Checking pod has DB_HOST env var from secret... "
POD_NAME=$(kubectl get pods -n staging -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    DB_HOST=$(kubectl exec "$POD_NAME" -n staging -- env 2>/dev/null | grep DB_HOST || true)
    if [ -n "$DB_HOST" ]; then
        echo "✅ PASS"
    else
        echo "❌ FAIL"
        ERRORS+="   - DB_HOST env var not found in pod\n"
        PASS=false
    fi
else
    echo "❌ SKIP (no pod found)"
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
