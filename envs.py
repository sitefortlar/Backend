import os
from dotenv import load_dotenv
from pydantic import SecretStr

# Carrega variáveis do arquivo .env
load_dotenv()

# Configurações do Banco de Dados
# Banco de Dados (PostgreSQL)
# 
# IMPORTANTE PARA PRODUÇÃO (Render.com, etc):
# O Supabase bloqueia conexões diretas de IPs externos. Use Connection Pooling!
# 
# OPÇÃO 1: URL completa (recomendado)
# Configure a variável SQLALCHEMY_DATABASE_URI com a URL completa:
# postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres
#
# OPÇÃO 2: Variáveis separadas (alternativa)
# Configure as variáveis separadas e a URL será construída automaticamente:
# - DB_USER (ex: postgres.zpcnvcthecltyiopstxd)
# - DB_PASSWORD (sua senha)
# - DB_HOST (ex: aws-1-us-east-1.pooler.supabase.com)
# - DB_PORT (ex: 5432)
# - DB_NAME (ex: postgres)
#
# IMPORTANTE: Sempre use Connection Pooling! A conexão direta é bloqueada pelo Supabase.
SQLALCHEMY_DATABASE_URI = os.getenv('SQLALCHEMY_DATABASE_URI')

# Se não tiver URL completa, tenta construir a partir de variáveis separadas
if not SQLALCHEMY_DATABASE_URI:
    db_user = os.getenv('DB_USER') or os.getenv('user')
    db_password = os.getenv('DB_PASSWORD') or os.getenv('password')
    db_host = os.getenv('DB_HOST') or os.getenv('host')
    db_port = os.getenv('DB_PORT') or os.getenv('port', '5432')
    db_name = os.getenv('DB_NAME') or os.getenv('dbname', 'postgres')
    
    # Se todas as variáveis estiverem disponíveis, constrói a URL
    if db_user and db_password and db_host:
        from urllib.parse import quote_plus
        # Codifica a senha para URL (trata caracteres especiais)
        encoded_password = quote_plus(db_password)
        SQLALCHEMY_DATABASE_URI = f'postgresql://{db_user}:{encoded_password}@{db_host}:{db_port}/{db_name}'
    else:
        # IMPORTANTE: Não use conexão direta! Configure Connection Pooling do Supabase
        # 
        # Para obter a URL de Connection Pooling:
        # 1. Acesse https://app.supabase.com
        # 2. Selecione seu projeto
        # 3. Vá em Settings > Database
        # 4. Na seção "Connection string", selecione a aba "Connection pooling"
        # 5. Copie a URL completa e configure como SQLALCHEMY_DATABASE_URI no .env
        #
        # Formato esperado:
        # postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres
        #
        # OU configure as variáveis DB_USER, DB_PASSWORD, DB_HOST separadamente
        # DB_HOST deve usar pooler.supabase.com (não db.xxx.supabase.co)
        raise ValueError(
            "SQLALCHEMY_DATABASE_URI não configurada!\n"
            "Configure a variável SQLALCHEMY_DATABASE_URI com a URL de Connection Pooling do Supabase.\n"
            "A conexão direta (db.xxx.supabase.co) é bloqueada pelo Supabase.\n"
            "Veja as instruções nos comentários acima ou em RENDER_DEPLOY.md"
        )

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
