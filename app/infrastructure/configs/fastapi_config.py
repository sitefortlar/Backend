import time
import os
from dotenv import load_dotenv

from app.presentation.routers.utils_router import utils_router

# Carrega as variáveis de ambiente antes de qualquer importação de routers
load_dotenv()

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from loguru import logger

# Exceptions
from app.application.exceptions.existing_record_exception import ExistingRecordException
from app.application.exceptions.not_found_record_exception import NotFoundRecordException
from app.application.exceptions.forbidden_exception import ForbiddenException
from app.application.exceptions.unprocessable_entity_exception import UnprocessableEntityException

# Routers
from app.presentation.routers.login_router import login_router
from app.presentation.routers.password_router import password_router
from app.presentation.routers.company_router import company_router
from app.presentation.routers.product_router import produto_router
from app.presentation.routers.category_router import category_router
from app.presentation.routers.order_router import order_router
from app.presentation.routers.contact_router import contact_router
from app.presentation.routers.address_router import address_router
from app.presentation.routers.email_token_router import email_token_router
from app.presentation.routers.region_router import region_router
from app.presentation.routers.upload_router import upload_router



# ==== Create Web Application Server
application = FastAPI(
    title="Fortlar API",
    description="""
    ## API do Sistema Fortlar
    
    Sistema de gestão de empresas, produtos, orders e kits.
    
    ### Funcionalidades Principais:
    - **Empresas**: Gestão completa de empresas com endereços e contatos
    - **Produtos**: Catálogo de produtos com categorias e preços
    - **Orders**: Sistema de orders com itens e status
    - **Kits**: Gestão de kits de produtos
    - **Categorias**: Organização de produtos por categorias
    
    ### Autenticação:
    - Sistema de login com JWT
    - Diferentes perfis de usuário (ADMIN, CLIENTE)
    
    ### Validações:
    - Validação de CNPJ único
    - Validação de email único
    - Validação de senha forte
    - Validação de dados obrigatórios
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    contact={
        "name": "Equipe Fortlar",
        "email": "vendas@fortlar.com.br",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    }
)
# ============================================================================
# CONFIGURAÇÃO DE CORS (Cross-Origin Resource Sharing)
# ============================================================================
# Permite múltiplas origens separadas por vírgula via variável de ambiente
# Exemplo: CORS_ORIGINS=https://seu-app.vercel.app,https://*.vercel.app,http://localhost:3000
# 
# IMPORTANTE: Se CORS_ORIGINS não estiver configurado, permite todas as origens (*)
# Para produção, é recomendado configurar as URLs específicas no Render.com
# ============================================================================
cors_origins_env = os.getenv("CORS_ORIGINS", "")

if cors_origins_env:
    # Se CORS_ORIGINS estiver configurado, usa as origens específicas
    cors_origins = [origin.strip() for origin in cors_origins_env.split(",") if origin.strip()]
    allow_credentials = True  # Permite credentials quando usa origens específicas
else:
    # Se não houver origens configuradas, permite todas (útil para desenvolvimento e produção)
    # Isso resolve o problema de CORS quando o frontend está em Vercel
    cors_origins = ["*"]
    allow_credentials = False  # Não pode usar credentials com wildcard "*"

application.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=allow_credentials,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"],  # Adicionado HEAD
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,  # Cache do preflight OPTIONS por 1 hora (melhora performance)
)


# Ajuste de timezone
os.environ['TZ'] = os.getenv("TZ", "America/Sao_Paulo")
time.tzset()

# ============================================================================
# CONFIGURAÇÃO DE ARQUIVOS ESTÁTICOS (Assets)
# ============================================================================
# Serve arquivos estáticos da pasta assets via /api/assets
# As imagens dos produtos serão acessíveis em: /api/assets/produtos/123.jpg
# ============================================================================
# Obtém o diretório raiz do projeto (3 níveis acima de fastapi_config.py)
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
assets_path = os.path.join(project_root, "assets")

# Cria a estrutura de pastas se não existir
if not os.path.exists(assets_path):
    os.makedirs(assets_path, exist_ok=True)
    logger.info(f"✅ Pasta assets criada: {assets_path}")

produtos_path = os.path.join(assets_path, "produtos")
if not os.path.exists(produtos_path):
    os.makedirs(produtos_path, exist_ok=True)
    logger.info(f"✅ Pasta produtos criada: {produtos_path}")

# Monta o diretório de arquivos estáticos
try:
    application.mount("/api/assets", StaticFiles(directory=assets_path), name="assets")
    logger.info(f"✅ Arquivos estáticos configurados: {assets_path}")
    logger.info(f"   Imagens acessíveis em: /api/assets/produtos/")
except Exception as e:
    logger.warning(f"⚠️ Não foi possível configurar arquivos estáticos: {e}")

# Incluir routers com prefixo /api
application.include_router(login_router, prefix="/api", tags=["Autenticação"])
application.include_router(password_router, prefix="/api", tags=["Autenticação"])
application.include_router(company_router, prefix="/api", tags=["Empresas"])
application.include_router(produto_router, prefix="/api", tags=["Produtos"])
application.include_router(category_router, prefix="/api", tags=["Categorias"])
application.include_router(order_router, prefix="/api", tags=["Orders"])
application.include_router(contact_router, prefix="/api", tags=["Contatos"])
application.include_router(address_router, prefix="/api", tags=["Endereços"])
application.include_router(email_token_router, prefix="/api", tags=["Token"])
application.include_router(region_router, prefix="/api", tags=["Regiões"])
application.include_router(utils_router, prefix="/api", tags=["Utilitários"])
application.include_router(upload_router, prefix="/api", tags=["Upload"])

# ==== Exception handlers ====
@application.exception_handler(ExistingRecordException)
async def existing_record_exception_handler(request: Request, exc: ExistingRecordException):
    return JSONResponse(content={"error": exc.args[0]}, status_code=422)

@application.exception_handler(NotFoundRecordException)
async def not_found_record_exception_handler(request: Request, exc: NotFoundRecordException):
    return JSONResponse(content={"error": exc.args[0]}, status_code=404)

@application.exception_handler(ForbiddenException)
async def forbidden_exception_handler(request: Request, exc: ForbiddenException):
    return JSONResponse(content={"error": exc.args[0]}, status_code=403)

@application.exception_handler(UnprocessableEntityException)
async def unprocessable_entity_exception_handler(request: Request, exc: UnprocessableEntityException):
    return JSONResponse(content={"error": exc.args[0]}, status_code=422)

@application.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    logger.error(f"Erro não tratado: {exc}")
    return JSONResponse(content={"error": "Erro interno do servidor"}, status_code=500)

