import os
from dotenv import load_dotenv
from pydantic import SecretStr

# Carrega variáveis do arquivo .env
load_dotenv()

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
SQLALCHEMY_DATABASE_URI = 'postgresql://postgres.zpcnvcthecltyiopstxd:j4W6dhjlLaEIpFvd@aws-1-us-east-1.pooler.supabase.com:5432/postgres'


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
MAIL_FROM="vendas@fortlar.com.br"
MAIL_PORT=587
MAIL_SERVER="smtp.gmail.com"


SUPABASE_URL='https://zpcnvcthecltyiopstxd.supabase.co'
SUPABASE_KEY='sb_secret_vY4aYPuED_Wfe8xFHl3_6Q_bTvPAqYn'
SUPABASE_BUCKET='products'
