from prometheus_api_client import PrometheusConnect
import pandas as pd
from sklearn.ensemble import IsolationForest

PROM_URL = "http://localhost:9090"

print("AI Anomaly Engine starting...")

try:
    prom = PrometheusConnect(url=PROM_URL, disable_ssl=True)
    data = prom.get_current_metric_value(metric_name="up")

    values = [float(d["value"][1]) for d in data]
    if not values:
        print("No metric data.")
        exit(0)

    df = pd.DataFrame(values, columns=["metric"])
    model = IsolationForest(contamination=0.2, random_state=42)
    df["anomaly"] = model.fit_predict(df)

    print(df)

    if -1 in df["anomaly"].values:
        print("⚠️ Anomaly detected!")

except Exception as e:
    print(f"Error: {e}")
