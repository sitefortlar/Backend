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
SQLALCHEMY_DATABASE_URI = os.getenv('SQLALCHEMY_DATABASE_URI')

# Se não tiver URL completa, tenta construir a partir de variáveis separadas
if not SQLALCHEMY_DATABASE_URI:
    # Suporta múltiplos nomes de variáveis para flexibilidade
    db_user = os.getenv('DB_USER') or os.getenv('user')
    db_password = os.getenv('DB_PASSWORD') or os.getenv('password')
    db_host = os.getenv('DB_HOST') or os.getenv('host')
    db_port = os.getenv('DB_PORT') or os.getenv('port', '5432')
    db_name = os.getenv('DB_NAME') or os.getenv('dbname', 'postgres')
    
    # Se todas as variáveis necessárias estiverem disponíveis, constrói a URL
    if db_user and db_password and db_host:
        from urllib.parse import quote_plus
        # Codifica a senha para URL (trata caracteres especiais como @, #, $, etc)
        encoded_password = quote_plus(db_password)
        SQLALCHEMY_DATABASE_URI = f'postgresql://{db_user}:{encoded_password}@{db_host}:{db_port}/{db_name}'
    else:
        # Detecta se está em ambiente de produção
        is_production = (
            os.getenv('RENDER') or 
            os.getenv('RENDER_SERVICE_NAME') or
            os.getenv('DYNO') or  # Heroku
            os.getenv('RAILWAY_ENVIRONMENT') or  # Railway
            os.getenv('VERCEL')  # Vercel
        )
        
        if is_production:
            # Em produção, exige configuração explícita (segurança)
            raise ValueError(
                "❌ SQLALCHEMY_DATABASE_URI não configurada!\n\n"
                "Configure a variável SQLALCHEMY_DATABASE_URI no Render.com com a URL de Connection Pooling.\n"
                "A conexão direta (db.xxx.supabase.co) é bloqueada pelo Supabase em produção.\n\n"
                "📋 Como obter a URL de Connection Pooling:\n"
                "1. Acesse https://app.supabase.com\n"
                "2. Selecione seu projeto\n"
                "3. Vá em Settings > Database\n"
                "4. Na seção 'Connection string', selecione a aba 'Connection pooling'\n"
                "5. Copie a URL completa (formato: postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres)\n"
                "6. Configure como SQLALCHEMY_DATABASE_URI no Render.com\n\n"
                "💡 Alternativa: Configure as variáveis DB_USER, DB_PASSWORD, DB_HOST separadamente"
            )
        else:
            # Em desenvolvimento local, permite fallback para conexão direta
            SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:%401234fortlar@db.zpcnvcthecltyiopstxd.supabase.co:5432/postgres'

# Valida se a URL está usando Connection Pooling em produção
if SQLALCHEMY_DATABASE_URI:
    is_production = os.getenv('RENDER') or os.getenv('RENDER_SERVICE_NAME')
    if is_production and 'pooler.supabase.com' not in SQLALCHEMY_DATABASE_URI:
        import warnings
        warnings.warn(
            "⚠️  A URL de conexão não está usando Connection Pooling (pooler.supabase.com). "
            "Isso pode causar erros 'Network is unreachable' em produção. "
            "Use Connection Pooling do Supabase para produção.",
            UserWarning
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
