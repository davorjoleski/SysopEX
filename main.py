from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import RedirectResponse   # 👈 важно

from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient
from urllib.parse import quote_plus
import os

# Load env vars
load_dotenv()

def env_or_raise(name):
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing environment variable: {name}")
    return value

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")

DB_USER_SAFE = quote_plus(DB_USER)
DB_PASS_SAFE = quote_plus(DB_PASS)






DATABASE_URL = f"postgresql://{DB_USER_SAFE}:{DB_PASS_SAFE}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require"

AZURE_CONN_STR = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
BLOB_CONTAINER = "uploads"

# DB setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)

Base.metadata.create_all(bind=engine)

# Azure Blob
blob_service = BlobServiceClient.from_connection_string(AZURE_CONN_STR)
try:
    blob_service.create_container(BLOB_CONTAINER)
except Exception:
    pass

# FastAPI app
app = FastAPI()

# 👇 root ќе редиректира кон Swagger UI
@app.get("/")
def root():
    return RedirectResponse(url="/docs")

# CRUD Users
@app.post("/users")
def create_user(name: str, email: str):
    db = SessionLocal()
    user = User(name=name, email=email)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"id": user.id, "name": user.name, "email": user.email}

@app.get("/users/{user_id}")
def read_user(user_id: int):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"id": user.id, "name": user.name, "email": user.email}

# Files
@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    blob_client = blob_service.get_blob_client(container=BLOB_CONTAINER, blob=file.filename)
    data = await file.read()
    blob_client.upload_blob(data, overwrite=True)
    return {"filename": file.filename, "url": blob_client.url}

@app.get("/download/{filename}")
def download_file(filename: str):
    blob_client = blob_service.get_blob_client(container=BLOB_CONTAINER, blob=filename)
    if not blob_client.exists():
        raise HTTPException(status_code=404, detail="File not found")
    return {"url": blob_client.url}
