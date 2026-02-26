# Kitchen App - Presentation Outline

Use this as a slide-by-slide structure for demo day, workshop delivery, or project defense.

---

## 1) Title Slide

- **Project:** Kitchen App - Cloud Native End-to-End
- **Subtitle:** Build, Deploy, Automate, Observe
- **Team/Presenter name**
- **Date**

Speaker note:
- Open with one sentence: “This project takes a Node.js kitchen order app from local development to Kubernetes, CI/CD, and observability.”

---

## 2) Problem Statement

- Teams often stop at “app works locally.”
- Real production readiness needs:
  - repeatable deployments,
  - pipeline validation,
  - monitoring,
  - clear troubleshooting.
- This project demonstrates that full lifecycle.

Speaker note:
- Emphasize this is not only a coding project; it is an operations-ready workflow.

---

## 3) Goals and Outcomes

- Build a 3-tier app (API + MongoDB + web UI).
- Expose Prometheus metrics from API.
- Deploy to Kubernetes reliably.
- Add CI/CD with 3-node Kind E2E testing.
- Add Grafana dashboards and validate runtime behavior.
- Make execution beginner-safe with strict runbooks.

---

## 4) Architecture Overview

- **API:** Node.js/Express (`/health`, `/ready`, `/orders`, `/metrics`)
- **DB:** MongoDB StatefulSet
- **UI:** Nginx-hosted static app with `/api` reverse proxy
- **Monitoring:** Prometheus + Grafana
- **Automation:** GitHub Actions pipeline

Suggested visual:
- Simple block diagram:
  - Browser -> web-ui -> API -> MongoDB
  - Prometheus <- API `/metrics`
  - Grafana <- Prometheus

---

## 5) Technology Stack

- Node.js 20 (also tested on Node 18 in CI)
- Express, MongoDB driver, prom-client
- Docker + Docker Compose
- Kubernetes (Docker Desktop / Kind in CI)
- GitHub Actions
- Prometheus, Grafana

---

## 6) Repo Structure Walkthrough

- `api/` - backend code, tests, Dockerfile
- `web-ui/` - frontend + nginx config
- `k8s/` - namespace, db, api, web-ui, monitoring manifests
- `.github/workflows/ci-cd.yml` - CI/CD pipeline
- `scripts/` - local setup and teardown
- `docs/` - student/instructor/prereq/workshop guides

Speaker note:
- Mention “single source of execution truth” in `docs/STUDENT_GUIDE.html`.

---

## 7) Phase-Based Delivery Model

- Phase 0: Tooling + preflight
- Phase 1: API core + tests
- Phase 2: Docker local execution
- Phase 3: Kubernetes manifests
- Phase 4: K8s deploy and validation
- Phase 5: CI/CD E2E pipeline
- Phase 6: Monitoring stack
- Phase 7: Order simulation behavior

Key message:
- Every phase has a gate; no phase is skipped.

---

## 8) Local Runtime Demo (Before K8s)

Demo checklist:
- `docker compose build`
- `docker compose up -d`
- `GET /health`
- `POST /orders`
- `GET /metrics`
- Open web UI

Success criteria:
- API + DB + UI healthy
- orders created successfully
- metrics visible

---

## 9) Kubernetes Deployment Strategy

- Strict apply order:
  1. Namespace
  2. Secret + ConfigMaps
  3. MongoDB StatefulSet
  4. API Deployment/Services
  5. Web UI Deployment/Service
- Rollout status checks after each stage
- Gate checks before moving to CI/CD

Speaker note:
- Highlight `api-server-override` configmap dependency.

---

## 10) Why Port-Forward Matters (Personal Laptops)

- On Windows + Docker Desktop, NodePort can be inconsistent.
- Reliable approach: separate terminal for each `kubectl port-forward`.
- Keep terminals open for API/UI/Prometheus/Grafana access.

Commands to show:
- API: `svc/api-nodeport 30000:3000`
- UI: `svc/web-ui-service 30080:80`
- Prometheus: `svc/prometheus-service 30090:9090`
- Grafana: `svc/grafana-service 30300:3000`

---

## 11) CI/CD Pipeline Deep Dive

Jobs:
- `matrix-test` (Node 18 + 20)
- `build-push` (build image artifacts)
- `e2e-k8s` (create Kind cluster, deploy, smoke test)

Smoke tests:
- API health = 200
- order create = 201
- metrics contains `http_requests_total`
- web UI responds = 200

---

## 12) Observability and Monitoring

- API emits:
  - `http_requests_total`
  - `http_request_duration_seconds`
  - `kitchen_orders_created_total`
- Prometheus scrapes API pods via annotations
- Grafana dashboard panels:
  - orders total
  - request rate
  - 5xx error rate
  - p95 latency
  - orders/sec
  - API memory + CPU

---

## 13) Business Behavior Validation

- Order simulation lifecycle:
  - `pending -> preparing -> ready -> served`
  - ~5 seconds per transition
- Backfill logic handles old unscheduled documents
- UI auto-refresh validates progression visually

---

## 14) Major Issues Faced and Fixes

- `0/1 READY` pods due to missing config dependencies
- image pull policy mismatches in local k8s
- YAML formatting errors
- CI rollout timeouts due to missing configmap step
- NodePort access issues on Windows

Key takeaway:
- Troubleshooting playbook + phase gates prevented random debugging.

---

## 15) 0/1 READY Troubleshooting Playbook (Highlight Slide)

- Quick triage:
  - `get pods`, `describe pod`, `logs`, `events`
- Symptom-specific recovery:
  - `CreateContainerConfigError`
  - `ImagePullBackOff`
  - probe failures
  - MongoDB readiness issues
- Known-good full recovery sequence in student guide

Reference:
- `docs/STUDENT_GUIDE.html` section: Kubernetes 0/1 READY Troubleshooting Playbook

---

## 16) Documentation System

- `PREREQUISITES.md` - setup + shell/terminal guardrails
- `STUDENT_GUIDE.html` - full execution runbook (copy-ready)
- `INSTRUCTOR_GUIDE.md` - classroom delivery strategy
- `WORKSHOP_SCHEDULE.md` - time planning and checkpoints

---

## 17) Final Results

- End-to-end app works:
  - before K8s (Docker)
  - after K8s deploy
  - inside CI E2E
- Monitoring and dashboards functional
- Reproducible workflow for learners

Suggested evidence slide:
- screenshots of:
  - pods/services healthy
  - order creation response
  - Grafana dashboard
  - successful GitHub Actions run

---

## 18) Lessons Learned

- Deployment order matters as much as code quality.
- “Works locally” is not enough without CI and observability.
- Explicit runbooks reduce onboarding and troubleshooting time.
- Windows laptop networking constraints require practical adaptations.

---

## 19) Future Improvements

- Add Helm chart packaging
- Add alert rules (Prometheus Alertmanager)
- Add auth and RBAC hardening for API/Grafana
- Add canary/blue-green deployment strategy
- Add persistent Grafana storage and dashboards as versioned assets

---

## 20) Q&A + Backup Slides

Prepare backup slides for:
- full CI workflow explanation
- 0/1 READY troubleshooting matrix
- detailed manifest snippets
- live fallback demo commands

---

## Optional Demo Script (5-minute quick demo)

1. Show `docker compose up -d` + API health.
2. Create order + show metrics endpoint.
3. Show k8s pods/services healthy.
4. Open web UI via port-forward.
5. Open Grafana dashboard and show live updates.
6. Show green GitHub Actions run.

