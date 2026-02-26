# Kitchen App — Instructor Guide

This guide helps instructors run an end-to-end training session for the Kitchen App project (Docker + Kubernetes + CI/CD + Monitoring), aligned with the current repository implementation.

---

## 1) Session Overview

## Audience
- Beginners to intermediate learners in DevOps / cloud-native development.
- Familiar with basic terminal usage and HTTP concepts.

## Total Duration (suggested)
- **One full-day workshop**: 6 to 7 hours (with breaks), or
- **Two half-day sessions**.

## Learning Outcomes
By the end, students should be able to:
- Build and run a 3-tier app locally using Docker Compose.
- Deploy the same app to Kubernetes using manifests.
- Diagnose common Kubernetes rollout/configuration failures.
- Configure and verify a CI/CD pipeline with GitHub Actions and Kind.
- Expose Prometheus metrics and visualize them in Grafana.
- Validate an automated order lifecycle simulation in the API.

---

## 2) Instructor Preparation Checklist

Run this before class day on your machine.

## Environment
- Git, Node 18 & 20, Docker Desktop, Kubernetes enabled, kubectl available.
- Stable internet for package/image pulls.
- GitHub account with repository access.

## Repo + Files
- Pull latest `main`.
- Confirm these files exist and are populated:
  - `api/server.js`
  - `docker-compose.yml`
  - `k8s/namespace.yaml`
  - `k8s/db/statefulset.yaml`
  - `k8s/api/deployment.yaml`
  - `k8s/web-ui/deployment.yaml`
  - `k8s/monitoring/prometheus-config.yaml`
  - `k8s/monitoring/grafana-deployment.yaml`
  - `k8s/monitoring/grafana-dashboard.yaml`
  - `.github/workflows/ci-cd.yml`
  - `scripts/local-setup.sh`
  - `scripts/teardown.sh`

## Dry Run (must pass)
- `docker compose build`
- `docker compose up -d`
- API health and metrics reachable.
- `bash scripts/local-setup.sh` succeeds.
- Monitoring manifests apply cleanly.
- Port-forward commands work from separate terminals.

---

## 3) Teaching Plan by Phase

The sequence follows the student guide flow.

## Delivery Mode Update (Important)

The canonical learner document is now `docs/STUDENT_GUIDE.html` and it is designed as:
- Build-from-scratch, file-by-file progression
- Strict phase gates ("do not proceed until current gate passes")
- OS-safe command variants (Windows/macOS/Linux)
- Explicit recovery section: **Kubernetes 0/1 READY Troubleshooting Playbook**

As instructor, enforce this flow strictly to avoid configuration drift across participants.

## Phase 0 — Prerequisites (20-30 min)

## Instructor goals
- Ensure every learner has required tools.
- Avoid losing time later on install or version issues.

## Live checks for students
```bash
git --version
node --version
npm --version
nvm list
docker --version
docker compose version
kubectl version --client
kubectl get nodes
```

## Common interventions
- Docker not running.
- Kubernetes context not set to `docker-desktop`.
- Node version mismatch (must support project and CI matrix expectations).

---

## Phase 1 — GitHub Workflow (20 min)

## Instructor goals
- Reinforce commit hygiene and iterative workflow.

## Talking points
- Why small commits reduce rollback risk.
- `feat`, `fix`, `docs`, `ci` commit prefixes.
- Difference between local success and remote CI success.

## Live demo
```bash
git status
git add .
git commit -m "feat: classroom baseline"
git push
```

---

## Phase 2 — Docker Local Runtime (60-75 min)

## Instructor goals
- Build confidence in local app behavior before Kubernetes.
- Make students verify API, UI, DB, and metrics together.

## Key architecture recap
- `db` (MongoDB)
- `api` (Express + Prometheus metrics + simulation worker)
- `web-ui` (Nginx static + `/api` proxy)

## Demo flow
```bash
docker compose build
docker compose up -d
docker compose ps
```

```bash
curl.exe http://localhost:3000/health
curl.exe http://localhost:3000/metrics
curl.exe -X POST http://localhost:3000/orders -H "Content-Type: application/json" -d "{\"dish\":\"Masala Dosa\"}"
curl.exe http://localhost:3000/orders
```

## Teach this explicitly
- Healthchecks in Compose influence startup ordering.
- `prom-client` metrics appear only after traffic.
- Order state auto-advances in background worker.

---

## Phase 3 — Kubernetes Concepts (30-40 min)

## Instructor goals
- Bridge "Compose thinking" to "Kubernetes objects".

## Mapping explanation
- Compose service -> Deployment/StatefulSet
- Compose env -> ConfigMap/Secret
- Compose ports -> Service/NodePort
- Container healthcheck -> Probe (liveness/readiness)

## Validation
```bash
kubectl cluster-info
kubectl get nodes
```

---

## Phase 4 — Kubernetes Deployment (90 min)

## Instructor goals
- Deploy with dependency order.
- Teach diagnostics when rollouts fail.

## Required order (important)
1. Namespace
2. Secret + ConfigMaps
3. MongoDB StatefulSet
4. API Deployment
5. Web UI Deployment

## Demo commands
```bash
kubectl apply -f k8s/namespace.yaml
```

```bash
kubectl create secret generic mongodb-secret \
  --from-literal=mongo-root-username=admin \
  --from-literal=mongo-root-password='Secret123!' \
  --from-literal=mongo-uri='mongodb://admin:Secret123!@mongodb-service.kitchen-app.svc.cluster.local:27017/kitchendb?authSource=admin' \
  --namespace kitchen-app --dry-run=client -o yaml | kubectl apply -f -
```

```bash
kubectl create configmap api-config \
  --from-literal=PORT=3000 \
  --namespace kitchen-app --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap api-server-override \
  --from-file=server.js=api/server.js \
  --namespace kitchen-app --dry-run=client -o yaml | kubectl apply -f -
```

```bash
kubectl apply -f k8s/db/statefulset.yaml
kubectl rollout status statefulset/mongodb -n kitchen-app --timeout=180s
kubectl apply -f k8s/api/deployment.yaml
kubectl rollout status deployment/api-deployment -n kitchen-app --timeout=180s
kubectl apply -f k8s/web-ui/deployment.yaml
kubectl rollout status deployment/web-ui-deployment -n kitchen-app --timeout=120s
```

## Verification block
```bash
kubectl get pods -n kitchen-app -o wide
kubectl get svc -n kitchen-app
```

## Multi-terminal classroom setup
- **Terminal A**: deploy/apply commands.
- **Terminal B**: `kubectl get pods -n kitchen-app -w`
- **Terminal C**: API port-forward in background.
- **Terminal D**: Web UI port-forward in background.
- **Terminal E/F** (optional): Prometheus and Grafana port-forward.

```bash
kubectl port-forward -n kitchen-app svc/api-nodeport 30000:3000
kubectl port-forward -n kitchen-app svc/web-ui-service 30080:80
kubectl port-forward -n kitchen-app svc/prometheus-service 30090:9090
kubectl port-forward -n kitchen-app svc/grafana-service 30300:3000
```

## Teaching note (Windows)
- NodePort on Docker Desktop can be inconsistent on localhost.
- Prefer `kubectl port-forward` for reliable classroom demos.

---

## Phase 5 — CI/CD (60 min)

## Instructor goals
- Show learners what "production-like confidence" looks like.
- Explain why lint + tests + deploy + smoke tests belong together.

## Pipeline walkthrough
- `matrix-test` (Node 18 + 20)
- `build-push` (build docker images as artifacts)
- `e2e-k8s` (3-node Kind, deploy all resources, smoke tests)

## Critical details to highlight
- Kind config must be file-based.
- `api-server-override` ConfigMap must exist before API apply.
- API rollout timeout is 180s.
- Monitoring deployment is conditional.

## Student activity
- Push a small docs/code change.
- Observe workflow jobs and identify where failures happen if introduced.

---

## Phase 6 — Monitoring (60-75 min)

## Instructor goals
- Make students read application behavior from metrics, not just logs.

## Deploy monitoring
```bash
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-dashboard.yaml
kubectl rollout restart deployment/grafana-deployment -n kitchen-app
```

## Background terminals
```bash
kubectl port-forward -n kitchen-app svc/prometheus-service 30090:9090
kubectl port-forward -n kitchen-app svc/grafana-service 30300:3000
```

## Live validation
- Prometheus query: `http_requests_total`
- Grafana login: `admin / kitchenadmin`
- Open dashboard: `Kitchen App — Overview`
- Generate traffic by creating orders from UI/API.

## Instructor prompts
- "Which panel confirms order creation throughput?"
- "How do you identify 5xx spikes?"
- "What does p95 latency tell you compared to average?"

---

## Phase 7 — Order Simulation & Behavioral Validation (35-45 min)

## Instructor goals
- Validate business behavior, not only service uptime.

## What to verify
- New order starts as `pending`.
- Transitions every ~5s: `preparing` -> `ready` -> `served`.
- Existing unscheduled orders are backfilled and continue transitions.

## Demo commands
```bash
curl.exe -X POST http://localhost:30000/orders -H "Content-Type: application/json" -d "{\"dish\":\"Idly\"}"
curl.exe http://localhost:30000/orders
```

## UI validation
- Open `http://localhost:30080`
- Watch status updates auto-refresh every 5 seconds.

---

## 4) Assessment Rubric

Use this for grading labs or capstone checks.

| Category | Pass Criteria |
|---|---|
| Local Docker run | All 3 services up, health endpoint returns 200 |
| API correctness | `/orders` create/list works, `/metrics` exposes required metrics |
| Kubernetes deploy | Namespace + secret/configmaps + DB/API/UI rollouts complete |
| Troubleshooting skill | Student can diagnose a failed pod with `describe` + `logs` |
| CI/CD understanding | Student explains 3 jobs and smoke test intent |
| Monitoring | Student opens Grafana dashboard and explains at least 2 panels |
| Simulation behavior | Student demonstrates status progression to `served` |

---

## 5) Common Failure Scenarios and Instructor Fixes

## A) `CreateContainerConfigError` (API)
Cause: missing ConfigMap or Secret.
Fix:
```bash
kubectl get configmap -n kitchen-app
kubectl get secret -n kitchen-app
```
Recreate missing items and restart deployment.

## B) YAML parsing errors
Cause: malformed inline YAML.
Fix: convert to block style; validate indentation.

## C) Mongo rollout timeout
Cause: probe too strict or slow startup.
Fix: inspect events/logs and adjust probe strategy.

## D) NodePort refused on Windows
Cause: local networking behavior with Docker Desktop.
Fix: move to `kubectl port-forward`.

## D2) Pod stuck at `0/1 READY`
Cause: varies (`CreateContainerConfigError`, probe failure, image pull issues, DB dependency).
Fix: use the exact **0/1 READY Troubleshooting Playbook** inside `docs/STUDENT_GUIDE.html` and run:
1) quick triage (`get/describe/logs/events`)
2) symptom-specific recovery block
3) known-good full recovery sequence

## E) CI API rollout timeout
Cause: missing `api-server-override` in workflow before API apply.
Fix: ensure workflow step order is correct.

## F) Order status not advancing
Cause: simulation errors or unscheduled legacy docs.
Fix: inspect API logs; verify worker and backfill logic.

---

## 6) Suggested Live Teaching Script

Use this quick script while presenting:

1. "We start with local confidence: Docker Compose."
2. "Now we move to orchestration: Kubernetes deployment order matters."
3. "Then we automate reliability: CI/CD in GitHub Actions with real K8s tests."
4. "Finally we observe behavior: Prometheus + Grafana + lifecycle simulation."
5. "If something fails, we debug with evidence, not guesses."

---

## 7) End-of-Class Final Verification

Run this once at the end:

```bash
kubectl get pods -n kitchen-app
kubectl get svc -n kitchen-app
curl.exe http://localhost:30000/health
curl.exe http://localhost:30000/metrics
curl.exe -X POST http://localhost:30000/orders -H "Content-Type: application/json" -d "{\"dish\":\"Final Demo\"}"
curl.exe http://localhost:30000/orders
```

Expected:
- All pods healthy.
- API and metrics reachable.
- New order appears and progresses status over time.
- Prometheus and Grafana show live updates.

---

## 8) Related Project Docs

- `docs/PREREQUISITES.md`
- `docs/STUDENT_GUIDE.html`
- `docs/WORKSHOP_SCHEDULE.md`

