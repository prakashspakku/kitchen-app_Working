# Kitchen App — Workshop Schedule

This schedule is designed for the current `kitchen-app` implementation and aligns with:
- `docs/PREREQUISITES.md`
- `docs/STUDENT_GUIDE.md`
- `docs/INSTRUCTOR_GUIDE.md`

---

## 1) Recommended Formats

## Option A: Full-Day Workshop (6.5 to 7 hours)
- Best for immersive hands-on delivery.
- Includes setup, build, deploy, CI/CD, monitoring, and troubleshooting.

## Option B: Two Half-Day Sessions
- Better for beginner cohorts and office-hours support.
- Day 1: prerequisites + Docker + Kubernetes core deploy.
- Day 2: CI/CD + monitoring + simulation + assessment.

---

## 2) Full-Day Detailed Schedule

| Time | Duration | Segment | Objectives | Mode |
|---|---:|---|---|---|
| 09:00-09:20 | 20 min | Kickoff + Architecture | Understand 3-tier app + learning outcomes | Lecture |
| 09:20-09:50 | 30 min | Phase 0: Prerequisites Validation | Verify Git/Node/Docker/kubectl/K8s context | Hands-on |
| 09:50-10:15 | 25 min | Phase 1: GitHub Workflow | Clone repo, branch/commit/push discipline | Demo + Hands-on |
| 10:15-11:10 | 55 min | Phase 2: Docker Compose | Build + run stack, verify health/orders/metrics | Hands-on |
| 11:10-11:25 | 15 min | Break | — | — |
| 11:25-12:05 | 40 min | Phase 3: Kubernetes Concepts | Map Compose to K8s objects | Lecture + Q&A |
| 12:05-13:15 | 70 min | Phase 4: K8s Deployment | Namespace, secret/configmaps, DB/API/UI rollout | Hands-on |
| 13:15-14:00 | 45 min | Lunch | — | — |
| 14:00-14:45 | 45 min | Phase 5: CI/CD Pipeline | Walk through 3-job GitHub Actions flow | Demo |
| 14:45-15:40 | 55 min | Phase 6: Monitoring | Deploy Prometheus/Grafana + dashboard validation | Hands-on |
| 15:40-16:10 | 30 min | Phase 7: Simulation Validation | Verify order lifecycle progression | Hands-on |
| 16:10-16:40 | 30 min | Troubleshooting Drill | Run failure scenarios + recovery commands | Group Lab |
| 16:40-17:00 | 20 min | Assessment + Wrap-up | Final verification checklist + feedback | Review |

---

## 3) Two Half-Day Schedule

## Day 1 (3.5-4 hours)

| Time | Duration | Segment |
|---|---:|---|
| 09:00-09:20 | 20 min | Kickoff + architecture |
| 09:20-09:50 | 30 min | Phase 0 prerequisite validation |
| 09:50-10:15 | 25 min | Phase 1 GitHub workflow |
| 10:15-11:10 | 55 min | Phase 2 Docker local run |
| 11:10-11:25 | 15 min | Break |
| 11:25-12:05 | 40 min | Phase 3 K8s concepts |
| 12:05-13:00 | 55 min | Phase 4 K8s deploy (core) |

## Day 2 (3.5-4 hours)

| Time | Duration | Segment |
|---|---:|---|
| 09:00-09:20 | 20 min | Recap + environment checks |
| 09:20-10:00 | 40 min | Phase 4 completion + access strategy |
| 10:00-10:45 | 45 min | Phase 5 CI/CD deep-dive |
| 10:45-11:00 | 15 min | Break |
| 11:00-11:50 | 50 min | Phase 6 monitoring stack |
| 11:50-12:20 | 30 min | Phase 7 simulation checks |
| 12:20-13:00 | 40 min | Troubleshooting + assessment |

---

## 4) Terminal Allocation Plan (Live Classroom)

Use this consistently to reduce confusion during hands-on execution.

| Terminal | Purpose | Typical Commands |
|---|---|---|
| Terminal A | Main execution | `docker compose ...`, `kubectl apply ...`, `rollout status` |
| Terminal B | Cluster watch | `kubectl get pods -n kitchen-app -w` |
| Terminal C | API access (background) | `kubectl port-forward -n kitchen-app svc/api 30000:3000` |
| Terminal D | Web UI access (background) | `kubectl port-forward -n kitchen-app svc/web-ui-service 30080:80` |
| Terminal E | Monitoring access (background) | Prometheus/Grafana port-forwards |
| Terminal F | Smoke tests | `curl.exe /health`, `/metrics`, `/orders` |

---

## 5) Session Deliverables (Per Participant)

By end of workshop, each participant should submit:

1. Working local Docker run screenshots/logs:
   - API health success
   - Web UI loaded
   - Order creation response

2. Kubernetes deploy evidence:
   - `kubectl get pods -n kitchen-app`
   - `kubectl get svc -n kitchen-app`

3. CI/CD evidence:
   - Successful GitHub Actions run (or partial with explained failure root cause)

4. Monitoring evidence:
   - Prometheus query result for `http_requests_total`
   - Grafana dashboard screenshot (Kitchen App — Overview)

5. Simulation evidence:
   - Same order showing status transition toward `served`

---

## 6) Instructor Checkpoints (Must-Pass Gates)

## Checkpoint 1 — Tooling Gate (Phase 0)
- All learners can run:
  - `docker --version`
  - `kubectl get nodes`
  - `node --version`

## Checkpoint 2 — Local Runtime Gate (Phase 2)
- `docker compose up -d` successful.
- `curl.exe http://localhost:3000/health` returns OK.
- `curl.exe http://localhost:3000/metrics` contains metrics.

## Checkpoint 3 — K8s Deploy Gate (Phase 4)
- All rollouts complete for MongoDB, API, web UI.
- Learners can access API and UI through port-forwards.

## Checkpoint 4 — CI/CD Gate (Phase 5)
- Learners can explain all three jobs:
  - `matrix-test`
  - `build-push`
  - `e2e-k8s`

## Checkpoint 5 — Observability Gate (Phase 6/7)
- Grafana dashboard loads.
- Learner can identify request rate and order metrics.
- Order lifecycle progression is visible.

---

## 7) Risk Buffer Plan (Time Protection)

Reserve these buffers inside each major block:

- **+10 min buffer** after Docker phase
- **+15 min buffer** after Kubernetes rollout phase
- **+10 min buffer** during CI/CD walkthrough
- **+10 min buffer** during monitoring setup

If delays occur:
- Prioritize hands-on outcomes over lecture detail.
- Use scripted deployment (`bash scripts/local-setup.sh`) to recover timeline.

---

## 8) Quick Recovery Decisions

If workshop time is running short:

1. Skip optional deep theory, keep command execution.
2. Use `local-setup.sh` instead of manual K8s steps.
3. Demo CI/CD centrally instead of every participant pushing.
4. Keep one monitoring walkthrough + one participant validation.
5. Ensure everyone still completes final verification checklist.

---

## 9) Final 20-Minute Closure Script

## 0-5 min
- Re-run end-to-end health checks:
```bash
kubectl get pods -n kitchen-app
curl.exe http://localhost:30000/health
```

## 5-10 min
- Create one final order and verify status lifecycle:
```bash
curl.exe -X POST http://localhost:30000/orders -H "Content-Type: application/json" -d "{\"dish\":\"Closure Demo\"}"
curl.exe http://localhost:30000/orders
```

## 10-15 min
- Open Grafana dashboard, show metrics update.

## 15-20 min
- Recap architecture + CI/CD + observability outcomes.
- Share next steps: hardening, scaling, alerting, Helm.

---

## 10) Links to Use During Delivery

- Student guide: `docs/STUDENT_GUIDE.md`
- HTML end-to-end guide: `docs/STUDENT_GUIDE_E2E.html`
- Instructor guide: `docs/INSTRUCTOR_GUIDE.md`
- Prerequisites: `docs/PREREQUISITES.md`

