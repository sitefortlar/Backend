import os
from dotenv import load_dotenv
from pydantic import SecretStr

# Carrega variáveis do arquivo .env
load_dotenv()

# Configurações do Banco de Dados
# Banco de Dados (PostgreSQL)
SQLALCHEMY_DATABASE_URI='postgresql://postgres:%401234fortlar@db.zpcnvcthecltyiopstxd.supabase.co:5432/postgres'

# Pool de Conexão
SQLALCHEMY_POOL_SIZE=15
SQLALCHEMY_MAX_OVERFLOW=20
SQLALCHEMY_POOL_TIMEOUT=30
SQLALCHEMY_POOL_RECYCLE=1800
SQLALCHEMY_POOL_PRE_PING=True

# Logs do SQL
SQLALCHEMY_SHOW_SQL=True

# JWT
JWT_SECRET_KEY='D41D8CD98F00B204E9800998ECF8427E'
JWT_ALGORITHM='HS256'
JWT_EXPIRATION_MINUTES=60

MAIL_USERNAME_ORDER='vendas@fortlar.com.br'  # Email para receber cópia dos orders

MAIL_USERNAME='sitefortlar@gmail.com'
MAIL_PASSWORD='odil hbbe zsfp xpdy'
MAIL_FROM="sitefortlar@gmail.com"
MAIL_PORT=587
MAIL_SERVER="smtp.gmail.com"


SUPABASE_URL='https://mougzelntqaynavihtql.supabase.co'
SUPABASE_KEY='sb_secret_NL6zzk5OODPbigHLMyA67A_KfXPplrM'
SUPABASE_BUCKET='products'
