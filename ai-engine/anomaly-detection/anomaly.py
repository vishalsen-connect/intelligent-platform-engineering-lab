import requests
from sklearn.ensemble import IsolationForest
import numpy as np

PROM_URL = "http://localhost:9090/api/v1/query"

query = 'sum(rate(container_cpu_usage_seconds_total[1m]))'

def fetch_metrics():
    r = requests.get(PROM_URL, params={"query": query})
    value = float(r.json()["data"]["result"][0]["value"][1])
    return value

data = [fetch_metrics() for _ in range(10)]

model = IsolationForest(contamination=0.1)
model.fit(np.array(data).reshape(-1, 1))

prediction = model.predict(np.array(data).reshape(-1, 1))

print("Anomaly Detection Result:", prediction)
