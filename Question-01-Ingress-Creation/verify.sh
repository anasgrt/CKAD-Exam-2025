#!/bin/bash
# Question 1: Ingress Creation - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Ingress exists
echo -n "1. Checking Ingress 'ingress-name' exists in namespace 'external'... "
if kubectl get ingress ingress-name -n external &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Ingress 'ingress-name' not found in namespace 'external'\n"
    PASS=false
fi

# Check 2: Host is correct
echo -n "2. Checking host is 'external.app.local'... "
HOST=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
if [ "$HOST" = "external.app.local" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Host is '$HOST', expected 'external.app.local'\n"
    PASS=false
fi

# Check 3: Path is /
echo -n "3. Checking path is '/'... "
PATH_VALUE=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.rules[0].http.paths[0].path}' 2>/dev/null)
if [ "$PATH_VALUE" = "/" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Path is '$PATH_VALUE', expected '/'\n"
    PASS=false
fi

# Check 4: PathType is Prefix
echo -n "4. Checking pathType is 'Prefix'... "
PATH_TYPE=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [ "$PATH_TYPE" = "Prefix" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - pathType is '$PATH_TYPE', expected 'Prefix'\n"
    PASS=false
fi

# Check 5: Backend service name is 'webapp'
echo -n "5. Checking backend service is 'webapp'... "
SVC_NAME=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$SVC_NAME" = "webapp" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Backend service is '$SVC_NAME', expected 'webapp'\n"
    PASS=false
fi

# Check 6: Backend service port is 8080
echo -n "6. Checking backend port is 8080... "
SVC_PORT=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' 2>/dev/null)
if [ "$SVC_PORT" = "8080" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Backend port is '$SVC_PORT', expected '8080'\n"
    PASS=false
fi

# Check 7: IngressClassName is nginx-exam
echo -n "7. Checking ingressClassName is 'nginx-exam'... "
INGRESS_CLASS=$(kubectl get ingress ingress-name -n external -o jsonpath='{.spec.ingressClassName}' 2>/dev/null)
if [ "$INGRESS_CLASS" = "nginx-exam" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - ingressClassName is '$INGRESS_CLASS', expected 'nginx-exam'\n"
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
