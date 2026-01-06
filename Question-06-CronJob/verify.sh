#!/bin/bash
# Question 6: CronJob Configuration - Verification

PASS=true
ERRORS=""

echo "🔍 Checking your answer..."
echo ""

# Check 1: CronJob exists
echo -n "1. Checking CronJob 'my-cronjob' exists... "
if kubectl get cronjob my-cronjob &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - CronJob 'my-cronjob' not found\n"
    PASS=false
fi

# Check 2: Schedule is */30 * * * *
echo -n "2. Checking schedule is '*/30 * * * *'... "
SCHEDULE=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [ "$SCHEDULE" = "*/30 * * * *" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Schedule is '$SCHEDULE', expected '*/30 * * * *'\n"
    PASS=false
fi

# Check 3: startingDeadlineSeconds is 17 (CronJob-level)
echo -n "3. Checking startingDeadlineSeconds is 17... "
START_DEADLINE=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.startingDeadlineSeconds}' 2>/dev/null)
if [ "$START_DEADLINE" = "17" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - startingDeadlineSeconds is '$START_DEADLINE', expected '17'\n"
    PASS=false
fi

# Check 4: activeDeadlineSeconds is 8 (Job-level)
echo -n "4. Checking activeDeadlineSeconds is 8... "
ACTIVE_DEADLINE=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}' 2>/dev/null)
if [ "$ACTIVE_DEADLINE" = "8" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - activeDeadlineSeconds is '$ACTIVE_DEADLINE', expected '8'\n"
    PASS=false
fi

# Check 5: successfulJobsHistoryLimit is 3 (CronJob-level)
echo -n "5. Checking successfulJobsHistoryLimit is 3... "
SUCCESS_LIMIT=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [ "$SUCCESS_LIMIT" = "3" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - successfulJobsHistoryLimit is '$SUCCESS_LIMIT', expected '3'\n"
    PASS=false
fi

# Check 6: failedJobsHistoryLimit is 1 (CronJob-level)
echo -n "6. Checking failedJobsHistoryLimit is 1... "
FAILED_LIMIT=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.failedJobsHistoryLimit}' 2>/dev/null)
if [ "$FAILED_LIMIT" = "1" ]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - failedJobsHistoryLimit is '$FAILED_LIMIT', expected '1'\n"
    PASS=false
fi

# Check 7: Image is busybox
echo -n "7. Checking image is 'busybox'... "
IMAGE=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == busybox* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Image is '$IMAGE', expected 'busybox'\n"
    PASS=false
fi

# Check 8: Command includes date and Hello
echo -n "8. Checking command includes 'date; echo Hello'... "
COMMAND=$(kubectl get cronjob my-cronjob -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command}' 2>/dev/null)
if [[ "$COMMAND" == *"date"* ]] && [[ "$COMMAND" == *"Hello"* ]]; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Command is '$COMMAND', expected to include 'date' and 'Hello'\n"
    PASS=false
fi

# Check 9: Job 'my-job' was created from CronJob
echo -n "9. Checking Job 'my-job' exists... "
if kubectl get job my-job &> /dev/null; then
    echo "✅ PASS"
else
    echo "❌ FAIL"
    ERRORS+="   - Job 'my-job' not found (use: kubectl create job my-job --from=cronjob/my-cronjob)\n"
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
