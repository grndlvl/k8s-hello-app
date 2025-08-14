# app/main.py

from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/healthz")    # readiness
def ready(): return {"ok": True}

@app.get("/livez")      # liveness
def live(): return {"ok": True}

@app.get("/")
def hello():
    return {"message": os.getenv("APP_MESSAGE", "Hello from Kubernetes!!!"), "env": os.getenv("APP_MODE","dev")}
