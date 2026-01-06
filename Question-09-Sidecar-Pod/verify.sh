#!/bin/bash
# Question 9: Multi-Container Sidecar Pod - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: Pod exists
echo -n "1. Checking pod 'sidecar-pod' exists... "
if kubectl get pod sidecar-pod &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod 'sidecar-pod' not found\n"
    PASS=false
fi

# Check 2: Main container 'main-app' exists in containers
echo -n "2. Checking container 'main-app' exists... "
MAIN_CONTAINER=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.containers[?(@.name=="main-app")].name}' 2>/dev/null)
if [ "$MAIN_CONTAINER" = "main-app" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Container 'main-app' not found in spec.containers\n"
    PASS=false
fi

# Check 3: Sidecar 'log-sidecar' exists in initContainers (native sidecar pattern)
echo -n "3. Checking sidecar 'log-sidecar' in initContainers... "
SIDECAR_CONTAINER=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.initContainers[?(@.name=="log-sidecar")].name}' 2>/dev/null)
if [ "$SIDECAR_CONTAINER" = "log-sidecar" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Container 'log-sidecar' not found in spec.initContainers\n"
    PASS=false
fi

# Check 4: Sidecar has restartPolicy: Always (native sidecar requirement)
echo -n "4. Checking sidecar has restartPolicy: Always... "
RESTART_POLICY=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.initContainers[?(@.name=="log-sidecar")].restartPolicy}' 2>/dev/null)
if [ "$RESTART_POLICY" = "Always" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Sidecar restartPolicy is '$RESTART_POLICY', expected 'Always'\n"
    PASS=false
fi

# Check 5: Volume 'log-volume' exists with emptyDir
echo -n "5. Checking volume 'log-volume' with emptyDir... "
VOLUME_NAME=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.volumes[?(@.name=="log-volume")].name}' 2>/dev/null)
VOLUME_TYPE=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.volumes[?(@.name=="log-volume")].emptyDir}' 2>/dev/null)
if [ "$VOLUME_NAME" = "log-volume" ] && [ -n "$VOLUME_TYPE" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Volume 'log-volume' with emptyDir not found\n"
    PASS=false
fi

# Check 6: Both containers mount volume at /var/log
echo -n "6. Checking both containers mount volume at /var/log... "
MAIN_MOUNT=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.containers[?(@.name=="main-app")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null)
SIDECAR_MOUNT=$(kubectl get pod sidecar-pod -o jsonpath='{.spec.initContainers[?(@.name=="log-sidecar")].volumeMounts[?(@.name=="log-volume")].mountPath}' 2>/dev/null)
if [ "$MAIN_MOUNT" = "/var/log" ] && [ "$SIDECAR_MOUNT" = "/var/log" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Volume mounts incorrect. main-app: '$MAIN_MOUNT', log-sidecar: '$SIDECAR_MOUNT'\n"
    PASS=false
fi

# Check 7: Pod is running
echo -n "7. Checking pod is running... "
STATUS=$(kubectl get pod sidecar-pod -o jsonpath='{.status.phase}' 2>/dev/null)
if [ "$STATUS" = "Running" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Pod status is '$STATUS', expected 'Running'\n"
    PASS=false
fi

# Check 8: Sidecar can read logs from shared volume
echo -n "8. Checking sidecar can read logs from main-app... "
sleep 6  # Wait for at least one log entry
LOG_OUTPUT=$(kubectl logs sidecar-pod -c log-sidecar --tail=1 2>/dev/null)
if [[ "$LOG_OUTPUT" == *"Log entry"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Sidecar not receiving logs from main container\n"
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
