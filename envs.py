import os
from dotenv import load_dotenv
from pydantic import SecretStr

# Carrega variáveis do arquivo .env
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
# CONFIGURAÇÕES DO BANCO DE DADOS (PostgreSQL - Supabase)
# ============================================================================
# 
# IMPORTANTE: O Supabase bloqueia conexões diretas de IPs externos.
# SEMPRE use Connection Pooling em produção (Render.com, etc)!
#
# OPÇÃO 1: URL completa (RECOMENDADO)
# Configure no Render.com: SQLALCHEMY_DATABASE_URI
# Formato: postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres
#
# OPÇÃO 2: Variáveis separadas (ALTERNATIVA)
# Configure no Render.com: DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME
# O código constrói a URL automaticamente.
#
# Como obter a URL de Connection Pooling:
# 1. Acesse https://app.supabase.com
# 2. Settings > Database > Connection string
# 3. Selecione "Connection pooling" (não "Direct connection")
# 4. Copie a URL completa
# ============================================================================

# Tenta obter URL completa das variáveis de ambiente
SQLALCHEMY_DATABASE_URI = os.getenv("SQLALCHEMY_DATABASE_URI", "")


# Pool de Conexão
SQLALCHEMY_POOL_SIZE = _get_int("SQLALCHEMY_POOL_SIZE", 15)
SQLALCHEMY_MAX_OVERFLOW = _get_int("SQLALCHEMY_MAX_OVERFLOW", 20)
SQLALCHEMY_POOL_TIMEOUT = _get_int("SQLALCHEMY_POOL_TIMEOUT", 30)
SQLALCHEMY_POOL_RECYCLE = _get_int("SQLALCHEMY_POOL_RECYCLE", 1800)
SQLALCHEMY_POOL_PRE_PING = _get_bool("SQLALCHEMY_POOL_PRE_PING", True)

# Logs do SQL
SQLALCHEMY_SHOW_SQL = _get_bool("SQLALCHEMY_SHOW_SQL", True)

# JWT
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRATION_MINUTES = _get_int("JWT_EXPIRATION_MINUTES", 60)

MAIL_USERNAME_ORDER = os.getenv("MAIL_USERNAME_ORDER", "")  # Email para receber cópia dos orders

MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
MAIL_FROM = os.getenv("MAIL_FROM", "")
MAIL_PORT = _get_int("MAIL_PORT", 587)
MAIL_SERVER = os.getenv("MAIL_SERVER", "")


SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")
SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET", "products")

# ============================================================================
# SUPABASE STORAGE VIA S3 (Opcional)
# ============================================================================
# Se você habilitar o "S3" em Storage no painel do Supabase, ele fornece um endpoint
# compatível com S3 + Access Key ID/Secret para acessar o Storage via boto3/AWS SDK.
#
# Onde pegar:
# Supabase Dashboard > Storage > S3
#
# Observação:
# - Para GET público em imagens, normalmente NÃO precisa de credenciais (bucket público + policy).
# - Para upload via S3 protocol, precisa de Access Key ID/Secret (ou IAM/role equivalente).
# ============================================================================

# Endpoint compatível com S3 (ex.: https://<ref>.supabase.co/storage/v1/s3)
SUPABASE_S3_ENDPOINT = os.getenv("SUPABASE_S3_ENDPOINT", "")

# Região (em muitos casos pode ser "us-east-1" ou a informada no painel S3 do Supabase)
SUPABASE_S3_REGION = os.getenv("SUPABASE_S3_REGION", "")

# Credenciais S3 do Supabase (NÃO commit em repo público; configure via .env no deploy)
SUPABASE_S3_ACCESS_KEY_ID = os.getenv("SUPABASE_S3_ACCESS_KEY_ID", "")
SUPABASE_S3_SECRET_ACCESS_KEY = os.getenv("SUPABASE_S3_SECRET_ACCESS_KEY", "")
