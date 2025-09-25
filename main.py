from dotenv import load_dotenv
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import RedirectResponse
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker
from azure.storage.blob import BlobServiceClient
from urllib.parse import quote_plus
import os

load_dotenv()

# --- Load & validate environment variables ---
def env(name: str) -> str:
    val = os.getenv(name)
    if not val:
        raise RuntimeError(f"Missing environment variable: {name}")
    return val

DB_HOST = env("DB_HOST")         # e.g. postgr.postgres.database.azure.com
DB_PORT = env("DB_PORT")         # e.g. 5432
DB_NAME = env("DB_NAME")         # e.g. postgres
DB_USER = env("DB_USER")         # e.g. adnim
DB_PASS = env("DB_PASS")         # e.g. StrongPassword!23@
AZURE_CONN_STR = env("AZURE_STORAGE_CONNECTION_STRING")

# --- Build database URL (escape special chars) ---
DB_USER_SAFE = quote_plus(DB_USER)
DB_PASS_SAFE = quote_plus(DB_PASS)

DATABASE_URL = (
    f"postgresql://{DB_USER_SAFE}:{DB_PASS_SAFE}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require"
)

# --- Database setup ---
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)

# Create tables at startup (for demo only)
Base.metadata.create_all(bind=engine)

# --- Azure Blob client ---
blob_service = BlobServiceClient.from_connection_string(AZURE_CONN_STR)
BLOB_CONTAINER = "uploads"
try:
    blob_service.create_container(BLOB_CONTAINER)
except Exception:
    # Ignore if container already exists
    pass

# --- FastAPI app ---
app = FastAPI()

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

# File Upload/Download
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
