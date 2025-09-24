from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import RedirectResponse
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient
from urllib.parse import quote_plus
import os

# --- Load environment variables ---
load_dotenv()

def env_or_raise(name: str) -> str:
    """Fetch env var or raise a clear error."""
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Missing environment variable: {name}")
    return value

# --- DB configuration ---
DB_HOST = env_or_raise("DB_HOST")
DB_PORT = env_or_raise("DB_PORT")
DB_NAME = env_or_raise("DB_NAME")
DB_USER = env_or_raise("DB_USER")
DB_PASS = env_or_raise("DB_PASS")

if not DB_USER or not DB_PASS:
    raise RuntimeError(f"Missing DB_USER or DB_PASS: {DB_USER=}, {DB_PASS=}")

DB_USER_SAFE = quote_plus(str(DB_USER))
DB_PASS_SAFE = quote_plus(str(DB_PASS))


DATABASE_URL = (
    f"postgresql://{DB_USER_SAFE}:{DB_PASS_SAFE}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require"
)

# --- Azure Blob configuration ---
AZURE_CONN_STR = env_or_raise("AZURE_STORAGE_CONNECTION_STRING")
BLOB_CONTAINER = "uploads"

# --- Database setup ---
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)

# Create tables on startup (for demo; for prod use Alembic migrations)
Base.metadata.create_all(bind=engine)

# --- Azure Blob client ---
blob_service = BlobServiceClient.from_connection_string(AZURE_CONN_STR)
try:
    blob_service.create_container(BLOB_CONTAINER)
except Exception:
    # Ignore if container already exists
    pass

# --- FastAPI application ---
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
