# 🚀 av-gitops — Production-Grade Kubernetes GitOps Platform

[![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-blue?style=flat-square&logo=argo)](https://argoproj.github.io/cd/)
[![Infrastructure](https://img.shields.io/badge/IaC-Terraform-purple?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-k3s-326CE5?style=flat-square&logo=kubernetes)](https://k3s.io/)
[![Cloud](https://img.shields.io/badge/Cloud-Hetzner-d50c2d?style=flat-square&logo=hetzner)](https://www.hetzner.com/)
[![Security](https://img.shields.io/badge/Secrets-1Password%20%2B%20ESO-black?style=flat-square&logo=1password)](https://external-secrets.io/)

A modern, fully automated Kubernetes platform built on **Hetzner Cloud** following industry-standard **GitOps** principles. This repository serves as the single source of truth for cluster infrastructure, core platform controllers, and self-hosted application workloads.

---

## 💡 Key Highlights & Architecture

- **100% Declarative GitOps**: Zero manual `kubectl` interventions after one-time bootstrap. Argo CD automatically syncs and self-heals cluster state from Git.
- **Enterprise-Grade Secrets Management**: Zero secrets stored in Git. External Secrets Operator (ESO) continuously syncs sensitive variables directly from **1Password Connect** into Kubernetes secrets.
- **Native Operator Patterns**: Dedicated stateful resources per application using CloudNativePG (PostgreSQL) and Dragonfly Operator (Redis-compatible memory cache).
- **Automated Ingress & TLS**: `ingress-nginx` combined with `cert-manager` for automated Let's Encrypt TLS certificate provisioning and renewals.
- **App-of-Apps Pattern**: Strict separation between core platform services and application workloads, avoiding sync dependencies and state conflicts.

---

## 🛠️ Technology Stack & Platform Components

| Layer | Technology | Role / Usage |
| :--- | :--- | :--- |
| **Infrastructure as Code** | **Terraform** | Provisions Hetzner Cloud VMs, networking, and k3s node configuration via GitHub Actions CI/CD. |
| **Cluster Runtime** | **k3s** | Lightweight, production-ready Kubernetes distribution optimized for performance and low memory footprint. |
| **Continuous Delivery** | **Argo CD** | Manages application lifecycle via `root-platform` and `root-apps` App-of-Apps controllers. |
| **Secrets Engine** | **External Secrets + 1Password** | Securely maps 1Password vault secrets into native K8s `Secrets`. |
| **Database** | **CloudNativePG Operator** | Cloud-native PostgreSQL operator provisioning isolated database clusters per app. |
| **In-Memory Cache** | **Dragonfly Operator** | Ultra-fast Redis-compatible cache operator. |
| **Ingress & TLS** | **ingress-nginx + cert-manager** | Public routing, SSL termination, and automated Let's Encrypt certificates. |

---

## 📂 Repository Structure

```text
av-gitops/
├── terraform/           # IaC: Hetzner VMs & k3s cluster setup
├── bootstrap/           # Initial ArgoCD installation & root application CRDs
├── platform/            # Core cluster infrastructure (Cert-Manager, CNPG, ESO, Ingress)
│   └── applications/    # ArgoCD Application CRs for platform tools
├── apps/                # Application definitions (ArgoCD Multi-Source Apps)
└── workloads/           # Application-specific K8s manifests (Postgres, Dragonfly, Ingress, Secrets)
```

---

## ➕ How to Onboard a New Application

Onboarding any new workload (`<app-name>`) to the cluster follows a standard **3-step pattern**:

### 1️⃣ Define Infrastructure Manifests (Optional)
If your app needs a database, cache, secrets, or ingress, create a directory in `workloads/<app-name>/` with standard Kubernetes resources:

```yaml
# workloads/<app-name>/postgres-cluster.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: <app-name>
  namespace: <app-name>
spec:
  instances: 1
  storage:
    size: 5Gi
```
*(Add `dragonfly.yaml`, `external-secret.yaml`, or `ingress.yaml` under `workloads/<app-name>/` as needed).*

---

### 2️⃣ Declare the Argo CD Application
Create `apps/<app-name>.yaml` using Argo CD **multi-source** to combine your app's Helm chart / manifests with its cluster infrastructure resources:

```yaml
# apps/<app-name>.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <app-name>
  namespace: argocd
spec:
  project: default
  sources:
    # Source 1: Application Helm Chart or source repository
    - repoURL: https://github.com/<your-org>/<app-repo>.git
      targetRevision: main
      path: charts/<app-name>
    # Source 2: Infrastructure & workload manifests in this GitOps repo
    - repoURL: https://github.com/Vasek18/av-gitops.git
      targetRevision: main
      path: workloads/<app-name>
  destination:
    server: https://kubernetes.default.svc
    namespace: <app-name>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

---

### 3️⃣ Commit & Push
```bash
git add apps/<app-name>.yaml workloads/<app-name>/
git commit -m "feat: onboard <app-name> application"
git push origin main
```

Argo CD (`root-apps`) will automatically detect `apps/<app-name>.yaml`, create the `<app-name>` target namespace, sync your application Helm chart, spin up its requested database/cache/ingress resources, and start serving traffic! 🚀

> **Reference Implementation:** See [`apps/my-hours.yaml`](apps/my-hours.yaml) and [`workloads/my-hours/`](workloads/my-hours/) for a live, working example of a Go + Vue app with Postgres, Dragonfly, External Secrets, and Ingress.
