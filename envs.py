import os
from dotenv import load_dotenv

load_dotenv()


def _get_int(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except Exception:
        return default


def _get_bool(name: str, default: bool) -> bool:
    val = os.getenv(name)
    if val is None:
        return default
    return str(val).strip().lower() in ("1", "true", "t", "yes", "y", "on")


# ============================================================================
# BANCO DE DADOS (PostgreSQL local via Docker)
# ============================================================================
SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI", "")
if not SQLALCHEMY_DATABASE_URI:
    raise RuntimeError("SQLALCHEMY_DATABASE_URI não configurado no .env")

POSTGRES_USER = os.getenv("POSTGRES_USER", "fortlar")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "")
POSTGRES_DB = os.getenv("POSTGRES_DB", "fortlar")

# Pool de conexões
SQLALCHEMY_POOL_SIZE = _get_int("SQLALCHEMY_POOL_SIZE", 15)
SQLALCHEMY_MAX_OVERFLOW = _get_int("SQLALCHEMY_MAX_OVERFLOW", 20)
SQLALCHEMY_POOL_TIMEOUT = _get_int("SQLALCHEMY_POOL_TIMEOUT", 30)
SQLALCHEMY_POOL_RECYCLE = _get_int("SQLALCHEMY_POOL_RECYCLE", 1800)
SQLALCHEMY_POOL_PRE_PING = _get_bool("SQLALCHEMY_POOL_PRE_PING", True)

SQLALCHEMY_SHOW_SQL = _get_bool("SQLALCHEMY_SHOW_SQL", False)

# ============================================================================
# JWT
# ============================================================================
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRATION_MINUTES = _get_int("JWT_EXPIRATION_MINUTES", 60)

# ============================================================================
# EMAIL
# ============================================================================
MAIL_USERNAME_ORDER = os.getenv("MAIL_USERNAME_ORDER", "")
MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
MAIL_FROM = os.getenv("MAIL_FROM", "")
MAIL_PORT = _get_int("MAIL_PORT", 587)
MAIL_SERVER = os.getenv("MAIL_SERVER", "")

# ============================================================================
# MINIO — STORAGE S3-COMPATÍVEL
# ============================================================================
# Endpoint interno (Docker network) — nome do serviço no docker-compose
MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "http://minio:9000")

# Credenciais de acesso do app ao MinIO
# Em produção: crie um usuário MinIO dedicado com permissões restritas
# Em desenvolvimento: use os mesmos valores de MINIO_ROOT_USER/PASSWORD
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", os.getenv("MINIO_ROOT_USER", "minioadmin"))
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", os.getenv("MINIO_ROOT_PASSWORD", "minioadmin"))

# Buckets separados por domínio de dados
MINIO_BUCKET_PRODUTOS = os.getenv("MINIO_BUCKET_PRODUTOS", "produtos")
MINIO_BUCKET_PLANILHAS = os.getenv("MINIO_BUCKET_PLANILHAS", "planilhas")

# URL base da API — usada para construir URLs públicas (via proxy /api/media)
APP_BASE_URL = os.getenv("APP_BASE_URL", "http://localhost:8000")

# ============================================================================
# RESEND (email transacional)
# ============================================================================
RESEND_API_KEY = os.getenv("RESEND_API_KEY", "")
RESEND_FROM_EMAIL = os.getenv("RESEND_FROM_EMAIL", "")
