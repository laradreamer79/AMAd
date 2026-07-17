# Ameen agent service — backend-only image (Flutter is excluded via .dockerignore).
FROM python:3.12-slim

# xgboost needs the OpenMP runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY agent/requirements.txt agent/requirements.txt
RUN pip install --no-cache-dir -r agent/requirements.txt

COPY decision_agent/ decision_agent/
COPY agent/ agent/

# Train the risk models and run the full test suites at BUILD time —
# a broken image must fail to build.
RUN cd decision_agent && python train.py
RUN python agent/test_workflow.py && python agent/test_routing.py

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD python -c "import sys, urllib.request; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=3).status == 200 else 1)"

CMD ["uvicorn", "agent.main:app", "--host", "0.0.0.0", "--port", "8000"]
