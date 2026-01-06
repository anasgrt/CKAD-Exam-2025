#!/bin/bash
# Question 20: Pod with Command - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Pod exists
echo -n "1. Checking pod 'simple-pod' exists... "
if kubectl get pod simple-pod -n cmd-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod 'simple-pod' not found in namespace 'cmd-ns'\n"
    PASS=false
fi

# Check 2: Image is busybox:1.35
echo -n "2. Checking image is busybox:1.35... "
IMAGE=$(kubectl get pod simple-pod -n cmd-ns -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "busybox:1.35"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'busybox:1.35'\n"
    PASS=false
fi

# Check 3: Command includes sleep
echo -n "3. Checking command includes 'sleep'... "
COMMAND=$(kubectl get pod simple-pod -n cmd-ns -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
ARGS=$(kubectl get pod simple-pod -n cmd-ns -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)
if [[ "$COMMAND" == *"sleep"* ]] || [[ "$ARGS" == *"sleep"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Command does not include 'sleep'. Command='$COMMAND', Args='$ARGS'\n"
    PASS=false
fi

# Check 4: Command includes 3600
echo -n "4. Checking command includes '3600'... "
if [[ "$COMMAND" == *"3600"* ]] || [[ "$ARGS" == *"3600"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Command does not include '3600'. Command='$COMMAND', Args='$ARGS'\n"
    PASS=false
fi

# Check 5: Pod is Running
echo -n "5. Checking pod is Running... "
sleep 5
POD_STATUS=$(kubectl get pod simple-pod -n cmd-ns -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$POD_STATUS" = "Running" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod status is '$POD_STATUS', expected 'Running'\n"
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
