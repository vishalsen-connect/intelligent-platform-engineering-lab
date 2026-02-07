CLUSTER_NAME=platform-lab
NS_MON=monitoring
NS_ING=ingress-nginx
NS_ARGO=argocd

create-cluster:
	kind create cluster --name $(CLUSTER_NAME) --config kind-config.yaml

delete-cluster:
	kind delete cluster --name $(CLUSTER_NAME)

install-ingress:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	kubectl create ns $(NS_ING) || true
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		-n $(NS_ING) -f kubernetes/ingress-nginx-values.yaml

install-monitoring:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	kubectl create ns $(NS_MON) || true
	helm upgrade --install kube-prom prometheus-community/kube-prometheus-stack \
		-n $(NS_MON) -f monitoring/kube-prometheus-values.yaml

install-argocd:
	kubectl create ns $(NS_ARGO) || true
	kubectl apply -n $(NS_ARGO) -f argocd/install.yaml

apply-argocd-apps:
	kubectl apply -f argocd/apps/sample-app.yaml

deploy-sample-app:
	kubectl apply -f kubernetes/apps/sample-app.yaml

run-ai:
	python3 ai-engine/anomaly-detection/anomaly.py

port-prom:
	bash scripts/port-forward-prom.sh

wait:
	bash scripts/wait-for-pods.sh

deploy: create-cluster install-ingress install-monitoring install-argocd wait apply-argocd-apps
destroy: delete-cluster