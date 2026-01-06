#!/bin/bash
echo "🧹 Cleaning up Question 11..."

# Function to force delete namespace if stuck in Terminating
force_delete_namespace() {
    local ns="$1"
    local timeout=10

    kubectl delete namespace "$ns" --ignore-not-found=true --wait=false 2>/dev/null

    # Wait briefly for normal deletion
    for i in $(seq 1 $timeout); do
        if ! kubectl get namespace "$ns" &>/dev/null; then
            return 0
        fi
        sleep 1
    done

    # If still exists and stuck in Terminating, force delete
    if kubectl get namespace "$ns" -o jsonpath='{.status.phase}' 2>/dev/null | grep -q "Terminating"; then
        echo "⏳ Namespace '$ns' stuck in Terminating. Force deleting..."
        kubectl get namespace "$ns" -o json | \
            jq '.spec.finalizers = []' | \
            kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f - >/dev/null 2>&1
        sleep 2
    fi
}

kubectl delete deployment web-app -n health-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete configmap nginx-config -n health-ns --ignore-not-found=true 2>/dev/null || true
force_delete_namespace "health-ns"
echo "✅ Cleanup complete!"
