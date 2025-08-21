# app/main.py
import os
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Greeting(BaseModel):
    message: str
    env: str
    pod_name: str

class SecretInfo(BaseModel):
    api_key: str
    db_password: str

class AppInfo(BaseModel):
    greeting: Greeting
    secrets: SecretInfo

class Status(BaseModel):
    status: str

@app.get("/", response_model=AppInfo)
def hello() -> AppInfo:
    greeting = Greeting(
        message=os.getenv("APP_MESSAGE", "Hello from Kubernetes!!!"),
        env=os.getenv("APP_MODE", "dev"),
        pod_name=os.getenv("HOSTNAME", "uknown")
    )

    secrets = SecretInfo(
        api_key=os.getenv("SECRET_API_KEY", "<unset>"),
        db_password=os.getenv("SECRET_DB_PASSWORD", "<unset>")
    )

    return AppInfo(
        greeting=greeting,
        secrets=secrets
    )

@app.get("/healthz")
def healthz() -> Status:
    return Status(status="ok")

@app.get("/livez")
def livez():
    return Status(status="alive")
