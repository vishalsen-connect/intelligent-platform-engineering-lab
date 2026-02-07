#############################################
# Intelligent Platform Engineering Lab
#############################################

SHELL := /bin/bash

# ---------- VARIABLES ----------
CLUSTER_NAME := intelligent-lab
KIND_CONFIG := kind-config.yaml

TERRAFORM_DIR := terraform/local
K8S_APPS_DIR := kubernetes/apps
MONITORING_VALUES := monitoring/kube-prometheus-values.yaml

ARGOCD_NAMESPACE := argocd
APP_NAMESPACE := demo

#############################################
# HELP
#############################################

help:
	@echo ""
	@echo "========= PLATFORM LAB COMMANDS ========="
	@echo ""
	@echo "make deploy            -> Full Deployment"
	@echo "make destroy           -> Full Cleanup"
	@echo ""
	@echo "make cluster-create    -> Create KIND cluster"
	@echo "make cluster-delete    -> Delete KIND cluster"
	@echo ""
	@echo "make terraform-apply   -> Apply Terraform"
	@echo "make terraform-destroy -> Destroy Terraform"
	@echo ""
	@echo "make argocd-install    -> Install ArgoCD (Helm)"
	@echo "make monitoring-install-> Install Monitoring"
	@echo "make deploy-apps       -> Deploy K8s Apps"
	@echo "make deploy-ai         -> Setup AI Engine"
	@echo "make ansible-bootstrap -> Run Ansible Setup"
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
# 🔥 ARGOCD INSTALL (FIXED USING HELM)
#############################################

argocd-install:
	@echo "Installing ArgoCD via Helm (Fix CRD error)"
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
# ARGO APPLICATIONS
#############################################

argocd-apps:
	kubectl apply -f argocd/install.yaml
	kubectl apply -f argocd/apps/

#############################################
# MONITORING
#############################################

monitoring-install:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
		-f $(MONITORING_VALUES) \
		-n monitoring --create-namespace
	bash scripts/wait-for-pods.sh monitoring

monitoring-delete:
	helm uninstall monitoring -n monitoring || true
	kubectl delete namespace monitoring --ignore-not-found

#############################################
# KUBERNETES APPS
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
# ANSIBLE
#############################################

ansible-bootstrap:
	ansible-playbook ansible/setup.yml

#############################################
# UTILITIES
#############################################

port-forward-prom:
	bash scripts/port-forward-prom.sh

pods:
	kubectl get pods -A

#############################################
# FULL DEPLOY
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
	@echo ""
	@echo "🚀 PLATFORM DEPLOYED SUCCESSFULLY"
	@echo ""

#############################################
# FULL DESTROY
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