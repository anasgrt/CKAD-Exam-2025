#!/bin/bash
# Question 12: Job with Failure Policy - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Job exists
echo -n "1. Checking job 'backup-job' exists... "
if kubectl get job backup-job -n job-ns &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Job 'backup-job' not found in namespace 'job-ns'\n"
    PASS=false
fi

# Check 2: Image is busybox:1.35
echo -n "2. Checking image is busybox:1.35... "
IMAGE=$(kubectl get job backup-job -n job-ns -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "busybox:1.35"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'busybox:1.35'\n"
    PASS=false
fi

# Check 3: backoffLimit is 3
echo -n "3. Checking backoffLimit=3... "
BACKOFF=$(kubectl get job backup-job -n job-ns -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
if [ "$BACKOFF" = "3" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - backoffLimit is '$BACKOFF', expected '3'\n"
    PASS=false
fi

# Check 4: activeDeadlineSeconds is 60
echo -n "4. Checking activeDeadlineSeconds=60... "
DEADLINE=$(kubectl get job backup-job -n job-ns -o jsonpath='{.spec.activeDeadlineSeconds}' 2>/dev/null)
if [ "$DEADLINE" = "60" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - activeDeadlineSeconds is '$DEADLINE', expected '60'\n"
    PASS=false
fi

# Check 5: Command contains required elements
echo -n "5. Checking command contains backup commands... "
COMMAND=$(kubectl get job backup-job -n job-ns -o jsonpath='{.spec.template.spec.containers[0].command}' 2>/dev/null)
ARGS=$(kubectl get job backup-job -n job-ns -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)
if [[ "$COMMAND $ARGS" == *"backup"* ]] || [[ "$COMMAND $ARGS" == *"echo"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Command does not contain backup commands\n"
    PASS=false
fi

# Check 6: Job succeeded or is running
echo -n "6. Checking job status... "
sleep 10
SUCCEEDED=$(kubectl get job backup-job -n job-ns -o jsonpath='{.status.succeeded}' 2>/dev/null)
ACTIVE=$(kubectl get job backup-job -n job-ns -o jsonpath='{.status.active}' 2>/dev/null)
if [ "$SUCCEEDED" = "1" ] || [ "$ACTIVE" = "1" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Job not running or succeeded. Succeeded='$SUCCEEDED', Active='$ACTIVE'\n"
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
