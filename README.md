# 🚀 Intelligent Platform Engineering Lab

> Production-Style DevOps + GitOps + AI Observability Platform  
> Built to demonstrate modern platform engineering practices using Kubernetes, ArgoCD, Terraform, Monitoring, and AI-driven anomaly detection.

---

# 🌟 Project Vision

This lab simulates a **real enterprise cloud-native platform** where:

- Infrastructure is automated via Terraform
- Applications are deployed via GitOps (ArgoCD)
- Observability is powered by Prometheus & Grafana
- AI Engine detects anomalies in metrics
- Everything runs in a reproducible local environment

---

# 🏗 Architecture

```
Developer → GitHub Repo
             ↓
          ArgoCD (GitOps)
             ↓
         Kubernetes Cluster
   ┌────────────┬──────────────┐
   │ Apps       │ Monitoring   │
   │            │              │
   │ Sample App │ Prometheus   │
   │            │ Grafana      │
   └────────────┴──────────────┘
             ↓
        AI Engine (Anomaly Detection)
```

---

# 📦 Tech Stack

| Category | Tools |
|----------|-----------|
| Container Platform | Kubernetes (KIND) |
| GitOps | ArgoCD |
| Infrastructure | Terraform |
| Monitoring | Prometheus + Grafana |
| Automation | Ansible |
| AI/ML | Python + Isolation Forest |
| Build Automation | Makefile |

---

# 📁 Repository Structure

```
intelligent-platform-engineering-lab
├── ai-engine
├── ansible
├── argocd
├── kubernetes
├── monitoring
├── terraform
├── scripts
├── Makefile
└── README.md
```

---

# 🖥 Prerequisites

Install the following:

## Core Tools

```
brew install kind kubectl helm terraform ansible python3
```

---

## Verify Installation

```
kubectl version --client
kind version
terraform version
helm version
ansible --version
python3 --version
```

---

# 🚀 Quick Start (One Command Deployment)

```
make deploy
```

This will:

✔ Create Kubernetes Cluster  
✔ Deploy Infrastructure  
✔ Install ArgoCD  
✔ Install Monitoring Stack  
✔ Deploy Sample Apps  
✔ Setup AI Engine  
✔ Run Ansible bootstrap  

---

# 📊 Accessing Services

---

## 🔹 ArgoCD Dashboard

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open:

```
https://localhost:8080
```

### Default Login

```
Username: admin
Password:
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

---

## 🔹 Grafana Dashboard

```
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
```

Open:

```
http://localhost:3000
```

### Default Login

```
admin / prom-operator
```

---

## 🔹 Prometheus UI

```
make port-forward-prom
```

Open:

```
http://localhost:9090
```

---

# 🤖 AI Anomaly Detection

Run AI Engine:

```
cd ai-engine/anomaly-detection
source .venv/bin/activate
python anomaly.py
```

This:

- Pulls Prometheus metrics
- Runs Isolation Forest ML model
- Detects abnormal system behaviour

---

# 🔄 GitOps Workflow

1. Modify Kubernetes YAML
2. Commit to GitHub
3. ArgoCD auto syncs changes
4. Kubernetes updates application

---

# 📦 Deploy Applications Only

```
make deploy-apps
```

---

# 📊 Monitoring Stack Deployment

```
make monitoring-install
```

Includes:

- Prometheus Operator
- Grafana
- Alert Manager

---

# 🧱 Infrastructure Deployment

```
make terraform-apply
```

---

# 🔧 Run Automation Bootstrap

```
make ansible-bootstrap
```

---

# 📊 Platform Observability Features

### Metrics Monitoring
- Node Metrics
- Pod Metrics
- Application Metrics

---

### Alerting
- High CPU usage alerts
- Pod health monitoring

---

### Dashboard
- Real-time cluster insights
- Performance monitoring

---

# 🎯 Use Cases

---

## Enterprise Platform Engineering

Demonstrates:

- GitOps driven delivery
- Automated infrastructure lifecycle
- Standardized monitoring

---

## AI Driven Observability

Shows:

- ML-based anomaly detection
- Predictive monitoring

---

## DevOps Automation

Includes:

- Infrastructure as Code
- Configuration management
- CI/CD simulation

---

## Disaster Recovery Testing

Supports:

- Automated teardown
- Reproducible environment rebuild

---

# 🧪 Demo Scenarios

---

## Scenario 1 — GitOps Sync

Modify app replicas:

```
kubernetes/apps/sample-app.yaml
```

Push change → Watch ArgoCD auto deploy

---

## Scenario 2 — Trigger Monitoring Alert

Simulate load → Watch Prometheus alert fire.

---

## Scenario 3 — Run AI Detection

Run anomaly script and observe output.

---

# 🧹 Destroy Environment

```
make destroy
```

Removes:

✔ Apps  
✔ Monitoring  
✔ ArgoCD  
✔ Infrastructure  
✔ AI Environment  
✔ Kubernetes Cluster  

---

# 🛠 Utility Commands

```
make pods
make port-forward-prom
```

---

# 🔐 Security Considerations

- Namespace isolation
- Infrastructure tagging
- GitOps drift detection

---

# 🧭 Future Enhancements

- Argo Rollouts Canary Deployment
- Chaos Engineering
- Slack Alert Integration
- Cost Monitoring (Kubecost)
- AI Auto Remediation

---

# 👨‍💻 Author

**Vishal Sen**  
Platform Engineer | DevOps Architect | AI Automation Enthusiast

---

# ⭐ Contribution

Pull requests welcome.  
Please open issue for suggestions.

---

# 📜 License

MIT License
