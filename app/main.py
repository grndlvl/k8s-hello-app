# app/main.py

from fastapi import FastAPI
import os
from pydantic import BaseModel

app = FastAPI()

class Greeting(BaseModel):
    message: str
    env: str

@app.get("/") 
def hello() -> Greeting:
    return Greeting(message=os.getenv("APP_MESSAGE", "Hello from Kubernetes!!!"), env=os.getenv("APP_MODE","dev"))

@app.get("/healthz")    # readiness
def ready(): return {"ok": True}

@app.get("/livez")      # liveness
def live(): return {"ok": True}
