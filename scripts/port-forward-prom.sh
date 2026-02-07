set -e
kubectl -n monitoring port-forward svc/kube-prom-kube-prometheus-prometheus 9090:9090
