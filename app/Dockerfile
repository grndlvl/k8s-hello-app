# -------- Build stage --------
FROM python:3.12-slim AS build

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# (Optional) tools for compiling wheels; remove if you only use pure wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Better caching: copy requirements first
COPY requirements.txt .

# Build a self-contained venv we can copy to runtime
RUN python -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
 && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Now bring in the app code
COPY . /app
# (Optional) byte-compile
RUN /opt/venv/bin/python -m compileall -q /app

# -------- Runtime stage --------
FROM python:3.12-slim

# Create non-root runtime user
RUN groupadd --gid 10001 app \
 && useradd --uid 10001 --gid 10001 --system --no-create-home --shell /usr/sbin/nologin app

# Copy only what we need from build stage
COPY --from=build /opt/venv /opt/venv
COPY --from=build /app /app
ENV PATH="/opt/venv/bin:${PATH}"

WORKDIR /app
RUN chown -R 10001:10001 /app
USER 10001:10001

EXPOSE 8080
# Typical FastAPI entrypoint
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
