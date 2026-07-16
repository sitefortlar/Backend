import time
import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
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
from app.presentation.routers.coupon_router import coupon_router
from app.presentation.routers.utils_router import utils_router
from app.presentation.routers.storage_test_router import storage_test_router


# ==== Lifespan — startup e shutdown ====
@asynccontextmanager
async def lifespan(app: FastAPI):
    from app.infrastructure.configs.database_config import init_db
    from app.application.service.storage_service import StorageService

    logger.info("Inicializando banco de dados...")
    init_db()
    logger.info("Banco de dados inicializado.")

    logger.info("Inicializando buckets MinIO...")
    StorageService.init_buckets()
    logger.info("Buckets MinIO prontos.")

    yield
    # shutdown: nada a liberar explicitamente (SQLAlchemy pool e boto3 encerram com o processo)


# ==== Aplicação ====
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
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
    contact={
        "name": "Equipe Fortlar",
        "email": "vendas@fortlar.com.br",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    },
)

# ==== CORS ====
cors_origins_env = os.getenv("CORS_ORIGINS", "")

if cors_origins_env:
    cors_origins = [origin.strip() for origin in cors_origins_env.split(",") if origin.strip()]
    allow_credentials = True
else:
    cors_origins = ["*"]
    allow_credentials = False

application.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=allow_credentials,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

# ==== Timezone ====
os.environ["TZ"] = os.getenv("TZ", "America/Sao_Paulo")
time.tzset()

# ==== Routers ====
application.include_router(login_router,       prefix="/api", tags=["Autenticação"])
application.include_router(password_router,    prefix="/api", tags=["Autenticação"])
application.include_router(company_router,     prefix="/api", tags=["Empresas"])
application.include_router(produto_router,     prefix="/api", tags=["Produtos"])
application.include_router(category_router,    prefix="/api", tags=["Categorias"])
application.include_router(order_router,       prefix="/api", tags=["Orders"])
application.include_router(contact_router,     prefix="/api", tags=["Contatos"])
application.include_router(address_router,     prefix="/api", tags=["Endereços"])
application.include_router(email_token_router, prefix="/api", tags=["Token"])
application.include_router(region_router,      prefix="/api", tags=["Regiões"])
application.include_router(utils_router,       prefix="/api", tags=["Utilitários"])
application.include_router(upload_router,      prefix="/api", tags=["Upload"])
application.include_router(coupon_router,      prefix="/api", tags=["Cupons"])
application.include_router(storage_test_router, prefix="/api", tags=["Storage Diagnóstico"])

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


# ==== Health checks ====
@application.get("/health/live", tags=["Health"], summary="Liveness — processo ativo")
async def health_live():
    """Docker healthcheck: confirma que o processo está rodando."""
    return {"status": "ok"}


@application.get("/health/ready", tags=["Health"], summary="Readiness — dependências ok")
async def health_ready():
    """Readiness check: verifica Postgres e MinIO antes de aceitar tráfego."""
    from sqlalchemy import text
    from app.infrastructure.configs.database_config import engine
    from app.application.service.storage_service import StorageService
    import envs

    errors = []

    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
    except Exception as e:
        errors.append(f"postgres: {e}")

    try:
        StorageService._ensure_client()
        StorageService._client.head_bucket(Bucket=envs.MINIO_BUCKET)
    except Exception as e:
        errors.append(f"minio: {e}")

    if errors:
        return JSONResponse({"status": "not ready", "errors": errors}, status_code=503)
    return {"status": "ready"}


# Alias legado mantido para compatibilidade
@application.get("/health", tags=["Health"], include_in_schema=False)
async def health_legacy():
    return {"status": "ok"}
