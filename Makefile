#############################################
# Intelligent Platform Engineering Lab
# Production POC Makefile
#############################################

SHELL := /bin/bash

# ---------- VARIABLES ----------
CLUSTER_NAME := intelligent-lab
KIND_CONFIG := kind-config.yaml

TERRAFORM_DIR := terraform/local
K8S_APPS_DIR := kubernetes/apps

MONITORING_VALUES := monitoring/kube-prometheus-values.yaml
SERVICEMONITOR := monitoring/sample-app-servicemonitor.yaml

ARGOCD_NAMESPACE := argocd
APP_NAMESPACE := demo

#############################################
# HELP
#############################################

help:
	@echo ""
	@echo "========= PLATFORM LAB COMMANDS ========="
	@echo ""
	@echo "make deploy              -> Full Platform Deployment"
	@echo "make destroy             -> Full Cleanup"
	@echo ""
	@echo "----- Infrastructure -----"
	@echo "make cluster-create"
	@echo "make cluster-delete"
	@echo "make terraform-apply"
	@echo "make terraform-destroy"
	@echo ""
	@echo "----- GitOps & Monitoring -----"
	@echo "make argocd-install"
	@echo "make monitoring-install"
	@echo "make poc-integrations"
	@echo ""
	@echo "----- Applications -----"
	@echo "make deploy-apps"
	@echo "make destroy-apps"
	@echo ""
	@echo "----- AI & Automation -----"
	@echo "make deploy-ai"
	@echo "make destroy-ai"
	@echo "make ansible-bootstrap"
	@echo ""
	@echo "----- Utilities -----"
	@echo "make port-forward-prom"
	@echo "make port-forward-grafana"
	@echo "make port-forward-argocd"
	@echo "make pods"
	@echo ""

#############################################
# KIND CLUSTER
#############################################

cluster-create:
	kind create cluster --name $(CLUSTER_NAME) --config $(KIND_CONFIG) || true

cluster-delete:
	kind delete cluster --name $(CLUSTER_NAME) || true

#############################################
# TERRAFORM
#############################################

terraform-init:
	cd $(TERRAFORM_DIR) && terraform init

terraform-apply: terraform-init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

terraform-destroy:
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve || true

#############################################
# NAMESPACES
#############################################

namespaces:
	kubectl create namespace $(APP_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -
	kubectl create namespace $(ARGOCD_NAMESPACE) --dry-run=client -o yaml | kubectl apply -f -

#############################################
# ARGOCD INSTALL
#############################################

argocd-install:
	@echo "Installing ArgoCD"
	helm repo add argo https://argoproj.github.io/argo-helm || true
	helm repo update
	helm upgrade --install argocd argo/argo-cd \
		--namespace $(ARGOCD_NAMESPACE) \
		--create-namespace
	bash scripts/wait-for-pods.sh $(ARGOCD_NAMESPACE)

argocd-delete:
	helm uninstall argocd -n $(ARGOCD_NAMESPACE) || true
	kubectl delete namespace $(ARGOCD_NAMESPACE) --ignore-not-found

#############################################
# ARGOCD APPLICATIONS (GitOps)
#############################################

argocd-apps:
	kubectl apply -f argocd/install.yaml
	kubectl apply -f argocd/apps/

#############################################
# MONITORING STACK
#############################################

monitoring-install:
	@echo "Installing Prometheus + Grafana"
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
		-f $(MONITORING_VALUES) \
		-n monitoring --create-namespace
	bash scripts/wait-for-pods.sh monitoring

	@echo "Applying ServiceMonitor"
	kubectl apply -f $(SERVICEMONITOR)

monitoring-delete:
	helm uninstall monitoring -n monitoring || true
	kubectl delete namespace monitoring --ignore-not-found

#############################################
# APPLICATION DEPLOYMENT
#############################################

deploy-apps:
	kubectl apply -n $(APP_NAMESPACE) -f $(K8S_APPS_DIR)

destroy-apps:
	kubectl delete -n $(APP_NAMESPACE) -f $(K8S_APPS_DIR) --ignore-not-found

#############################################
# AI ENGINE
#############################################

deploy-ai:
	cd ai-engine/anomaly-detection && python3 -m venv .venv
	cd ai-engine/anomaly-detection && source .venv/bin/activate && pip install -r requirements.txt
	@echo "AI Engine Ready"

destroy-ai:
	rm -rf ai-engine/anomaly-detection/.venv || true

#############################################
# ANSIBLE AUTOMATION
#############################################

ansible-bootstrap:
	ansible-playbook ansible/setup.yml

#############################################
# POC INTEGRATION TARGET
#############################################

poc-integrations:
	@echo "Applying ArgoCD Applications"
	kubectl apply -f argocd/apps/

	@echo "Applying Monitoring Integrations"
	kubectl apply -f $(SERVICEMONITOR)

	@echo "POC Integrations Enabled"

#############################################
# UTILITIES
#############################################

port-forward-prom:
	kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring

port-forward-grafana:
	kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring

port-forward-argocd:
	kubectl port-forward svc/argocd-server 8080:443 -n argocd

pods:
	kubectl get pods -A

#############################################
# FULL PLATFORM DEPLOYMENT
#############################################

deploy:
	$(MAKE) cluster-create
	$(MAKE) terraform-apply
	$(MAKE) namespaces
	$(MAKE) argocd-install
	$(MAKE) monitoring-install
	$(MAKE) deploy-apps
	$(MAKE) deploy-ai
	$(MAKE) ansible-bootstrap
	$(MAKE) poc-integrations
	@echo ""
	@echo "🚀 PLATFORM DEPLOYED SUCCESSFULLY"
	@echo ""

#############################################
# FULL PLATFORM DESTROY
#############################################

destroy:
	$(MAKE) destroy-apps
	$(MAKE) monitoring-delete
	$(MAKE) argocd-delete
	$(MAKE) terraform-destroy
	$(MAKE) destroy-ai
	$(MAKE) cluster-delete
	@echo ""
	@echo "🧹 PLATFORM CLEANED"
	@echo ""
