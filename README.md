# CKAD 2025 Exam Questions & Answers - Practice Simulator

Complete practice environment for 20 CKAD 2025 exam questions extracted from verified candidate reports.

**Source:** Verified 2025 CKAD candidate reports (May-December 2025)
**Total Questions:** 20

## Prerequisites

- Access to a Kubernetes cluster (k3s, kind, minikube, or any dev cluster)
- `kubectl` configured and working
- `podman` or `docker` for container image questions
- Metrics server for resource monitoring questions (optional, verification will adapt)

## Quick Start

```bash
cd CKAD-2025-Exam

# List all available questions
./scripts/run-question.sh list

# Start a question (sets up environment + shows question)
./scripts/run-question.sh Question-01-Ingress-Creation

# Verify your answer
./scripts/run-question.sh Question-01-Ingress-Creation verify

# View solution if stuck
./scripts/run-question.sh Question-01-Ingress-Creation solution

# Reset/cleanup
./scripts/run-question.sh Question-01-Ingress-Creation reset
```

## Questions Overview

| # | Question | Domain | Weight |
|---|----------|--------|--------|
| 1 | Ingress Creation | Services & Networking | ~7% |
| 2 | Fix Broken Ingress (404 Error) | Services & Networking | ~5% |
| 3 | Fix Broken Deployment (Incorrect Secret) | Application Deployment | ~5% |
| 4 | NetworkPolicy - Adjust Pod Labels | Services & Networking | ~7% |
| 5 | ResourceQuota Compliance | Configuration and Security | ~5% |
| 6 | CronJob Configuration | Application Design and Build | ~7% |
| 7 | ServiceAccount Selection | Configuration and Security | ~5% |
| 8 | Canary Deployment | Application Deployment | ~8% |
| 9 | Multi-Container Sidecar Pod | Application Design and Build | ~7% |
| 10 | Expose Deployment with NodePort | Services & Networking | ~5% |
| 11 | Deployment Debugging | Application Deployment | ~8% |
| 12 | Fix Deprecated API Version | Application Deployment | ~5% |
| 13 | Liveness & Readiness Probes | Application Observability | ~7% |
| 14 | Create Job with Failure Policy | Application Design and Build | ~5% |
| 15 | Docker Build + Export to OCI Format | Application Design and Build | ~4% |
| 16 | Service Selector Fix | Services & Networking | ~5% |
| 17 | SecurityContext Configuration | Configuration and Security | ~7% |
| 18 | RBAC - Fix Forbidden Error | Configuration and Security | ~8% |
| 19 | Pod with Command (Keep Running) | Application Design and Build | ~4% |
| 20 | Create Secret with Multiple Keys | Configuration and Security | ~7% |

## Workflow

1. **Setup**: `./scripts/run-question.sh Question-XX` - Creates resources and shows question
2. **Solve**: Use kubectl to complete the task
3. **Verify**: `./scripts/run-question.sh Question-XX verify` - Check your answer
4. **Solution**: `./scripts/run-question.sh Question-XX solution` - View solution if stuck
5. **Reset**: `./scripts/run-question.sh Question-XX reset` - Clean up before next attempt

## Directory Structure

```
CKAD-2025-Exam/
├── scripts/
│   └── run-question.sh      # Main runner script
├── Question-01-Ingress-Creation/
│   ├── setup.sh             # Environment setup
│   ├── question.txt         # Question text
│   ├── verify.sh            # Answer verification
│   ├── solution.sh          # Solution with explanations
│   └── reset.sh             # Cleanup script
├── Question-02-Fix-Broken-Ingress/
│   └── ...
└── README.md
```

## Exam Tips

1. **Always switch context first** before answering any question
2. **Use imperative commands** when possible to save time
3. **Use K8s documentation** - know search keywords
4. **Verify your work** - always check pods are running
5. **Practice Linux commands** - sort, awk, grep, head are essential

## Commands Cheat Sheet

```bash
# Context
kubectl config use-context <context>

# Create resources
kubectl create secret generic <n> --from-literal=key=value
kubectl create ns <namespace>
kubectl run <pod> --image=<image> --port=<port>

# Edit & Update
kubectl edit deployment <n> -n <ns>
kubectl set image deployment/<n> <container>=<image>
kubectl scale deployment <n> --replicas=N

# Rollouts
kubectl rollout status deployment/<n>
kubectl rollout history deployment/<n>
kubectl rollout undo deployment/<n>

# Debug
kubectl logs <pod> -n <ns>
kubectl exec -it <pod> -- /bin/sh
kubectl describe pod <pod> -n <ns>
kubectl top pod -n <ns>

# RBAC
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<ns>:<sa>

# Ingress
kubectl create ingress <name> --rule="host/path=svc:port"

# NetworkPolicy
kubectl label pod <pod> <key>=<value>
```

## Source

Questions compiled from verified 2025 CKAD candidate reports from various sources including:
- KodeKloud Community
- Tech With Mohamed
- Pass4Success
- LinuxDataHub
- Multiple Reddit and forum testimonials
