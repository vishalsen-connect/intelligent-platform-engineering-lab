set -e
echo "Waiting for core pods..."
kubectl wait --for=condition=Ready pods --all -A --timeout=300s || true
