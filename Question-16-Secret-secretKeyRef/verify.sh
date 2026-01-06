#!/bin/bash
# Question 16: Secret with Multiple Keys - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Secret exists
echo -n "1. Checking secret 'db-secret' exists... "
if kubectl get secret db-secret -n secret-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Secret 'db-secret' not found in namespace 'secret-ns'\n"
    PASS=false
fi

# Check 2: Secret has DB_HOST
echo -n "2. Checking secret has DB_HOST key... "
DB_HOST=$(kubectl get secret db-secret -n secret-ns -o jsonpath='{.data.DB_HOST}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$DB_HOST" = "mysql.database.svc" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_HOST is '$DB_HOST', expected 'mysql.database.svc'\n"
    PASS=false
fi

# Check 3: Secret has DB_USER
echo -n "3. Checking secret has DB_USER key... "
DB_USER=$(kubectl get secret db-secret -n secret-ns -o jsonpath='{.data.DB_USER}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$DB_USER" = "admin" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_USER is '$DB_USER', expected 'admin'\n"
    PASS=false
fi

# Check 4: Secret has DB_PASSWORD
echo -n "4. Checking secret has DB_PASSWORD key... "
DB_PASSWORD=$(kubectl get secret db-secret -n secret-ns -o jsonpath='{.data.DB_PASSWORD}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$DB_PASSWORD" = "secret123" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_PASSWORD is '$DB_PASSWORD', expected 'secret123'\n"
    PASS=false
fi

# Check 5: Secret has DB_NAME
echo -n "5. Checking secret has DB_NAME key... "
DB_NAME=$(kubectl get secret db-secret -n secret-ns -o jsonpath='{.data.DB_NAME}' 2>/dev/null | base64 -d 2>/dev/null)
if [ "$DB_NAME" = "myapp" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_NAME is '$DB_NAME', expected 'myapp'\n"
    PASS=false
fi

# Check 6: Deployment exists
echo -n "6. Checking deployment 'db-app' exists... "
if kubectl get deployment db-app -n secret-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Deployment 'db-app' not found in namespace 'secret-ns'\n"
    PASS=false
fi

# Check 7: Deployment uses secretKeyRef for DB_HOST
echo -n "7. Checking DB_HOST uses secretKeyRef... "
SECRET_REF=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_HOST")].valueFrom.secretKeyRef.name}' 2>/dev/null)
SECRET_KEY=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_HOST")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [ "$SECRET_REF" = "db-secret" ] && [ "$SECRET_KEY" = "DB_HOST" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_HOST secretKeyRef: name='$SECRET_REF', key='$SECRET_KEY', expected name='db-secret', key='DB_HOST'\n"
    PASS=false
fi

# Check 7b: Deployment uses secretKeyRef for DB_PASSWORD
echo -n "7b. Checking DB_PASSWORD uses secretKeyRef... "
SECRET_REF=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.name}' 2>/dev/null)
SECRET_KEY=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="DB_PASSWORD")].valueFrom.secretKeyRef.key}' 2>/dev/null)
if [ "$SECRET_REF" = "db-secret" ] && [ "$SECRET_KEY" = "DB_PASSWORD" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - DB_PASSWORD secretKeyRef: name='$SECRET_REF', key='$SECRET_KEY', expected name='db-secret', key='DB_PASSWORD'\n"
    PASS=false
fi

# Check 8: Deployment pods are Running
echo -n "8. Checking deployment pods are Running... "
sleep 5
READY_REPLICAS=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
DESIRED_REPLICAS=$(kubectl get deployment db-app -n secret-ns -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$READY_REPLICAS" = "$DESIRED_REPLICAS" ] && [ -n "$READY_REPLICAS" ]; then
    echo "✅ PASS ($READY_REPLICAS/$DESIRED_REPLICAS ready)"
else
    echo "❌ FAIL"
    ERRORS+="   - Ready replicas: '$READY_REPLICAS', expected: '$DESIRED_REPLICAS'\n"
    PASS=false
fi

# Check 9: Environment variables are set in pods
echo -n "9. Checking env vars are accessible in pods... "
POD_NAME=$(kubectl get pods -n secret-ns -l app=db-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    POD_DB_HOST=$(kubectl exec "$POD_NAME" -n secret-ns -- env 2>/dev/null | grep "DB_HOST" || true)
    if [[ "$POD_DB_HOST" == *"mysql.database.svc"* ]]; then
        echo "✅ PASS"
    else
        echo "❌ FAIL"
        ERRORS+="   - Environment variable DB_HOST not found or incorrect in pod\n"
        PASS=false
    fi
else
    echo "❌ FAIL"
    ERRORS+="   - No running pods found for deployment\n"
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
