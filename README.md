# Intelligent Platform Engineering Lab

## Use Cases
- Platform bootstrap
- GitOps delivery
- AI-assisted operations
- Lifecycle automation

## Deploy
make deploy

## Access Prometheus
make port-prom
http://localhost:9090

## Run AI Engine
pip install -r ai-engine/anomaly-detection/requirements.txt
make run-ai

## Destroy
make destroy
