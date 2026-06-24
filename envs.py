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
# Hostname "postgres" é o nome do serviço no docker-compose.
# Formato: postgresql://usuario:senha@postgres:5432/nome_banco
SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI", "")

POSTGRES_USER = os.getenv("POSTGRES_USER", "fortlar")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "")
POSTGRES_DB = os.getenv("POSTGRES_DB", "fortlar")

# Pool de conexões
SQLALCHEMY_POOL_SIZE = _get_int("SQLALCHEMY_POOL_SIZE", 15)
SQLALCHEMY_MAX_OVERFLOW = _get_int("SQLALCHEMY_MAX_OVERFLOW", 20)
SQLALCHEMY_POOL_TIMEOUT = _get_int("SQLALCHEMY_POOL_TIMEOUT", 30)
SQLALCHEMY_POOL_RECYCLE = _get_int("SQLALCHEMY_POOL_RECYCLE", 1800)
SQLALCHEMY_POOL_PRE_PING = _get_bool("SQLALCHEMY_POOL_PRE_PING", True)

# Logs de SQL (desativar em produção)
SQLALCHEMY_SHOW_SQL = _get_bool("SQLALCHEMY_SHOW_SQL", False)

# ============================================================================
# JWT — AUTENTICAÇÃO
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
# Endpoint interno (Docker network) — usado pelo backend para put/get/delete
MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "http://fortlar-minio:9000")

# Credenciais (definidas no docker-compose como MINIO_ROOT_USER/PASSWORD)
MINIO_ROOT_USER = os.getenv("MINIO_ROOT_USER", "minioadmin")
MINIO_ROOT_PASSWORD = os.getenv("MINIO_ROOT_PASSWORD", "minioadmin")

# Bucket padrão para todos os arquivos (imagens e planilhas)
MINIO_BUCKET = os.getenv("MINIO_BUCKET", "fortlar")

# URL base da API — usada para construir URLs públicas (via proxy /api/media)
# Ex: https://api.fortlar.com.br  ou  http://localhost:8000
APP_BASE_URL = os.getenv("APP_BASE_URL", "http://localhost:8000")
