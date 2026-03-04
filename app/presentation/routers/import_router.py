"""Router para importação de planilha base de produtos (persiste no banco)."""

import tempfile
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, status, Query, BackgroundTasks
from fastapi.responses import JSONResponse
from loguru import logger

from app.application.service.job_service import JobService
from app.domain.models.enumerations.role_enumerations import RoleEnum
from app.infrastructure.configs.security_config import verify_user_permission

# Reutiliza o processamento assíncrono do product_router (persiste produtos no banco)
from app.presentation.routers.product_router import _process_product_upload_async

import_router = APIRouter(
    prefix="/import",
    tags=["Importação"],
    responses={
        400: {"description": "Arquivo inválido"},
        500: {"description": "Erro interno do servidor"},
    },
)


@import_router.post(
    "/upload-planilha-base",
    summary="Importar planilha base de produtos (atualiza o banco)",
    description="""
    Faz upload de uma planilha CSV ou Excel e **atualiza a base de dados**:
    - Se o **código do produto já existir**: aplica as mudanças da planilha (nome, descrição, preço, categoria, etc.).
    - Se **não existir**: cria o produto.
    Processamento é assíncrono; use o `job_id` retornado para consultar o status em `GET /api/product/job/{job_id}`.

    **Query params:**
    - `clean_before`: se `true`, remove todos os produtos antes de importar (substituição total).
    """,
)
async def upload_planilha_base(
    file: UploadFile = File(..., description="Arquivo CSV ou Excel com produtos"),
    clean_before: bool = Query(False, description="Se true, limpa a base antes de importar"),
    background_tasks: BackgroundTasks = BackgroundTasks(),
    current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN)),
):
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Nome do arquivo é obrigatório",
        )
    file_ext = file.filename.lower()
    is_csv = file_ext.endswith(".csv")
    is_excel = file_ext.endswith((".xlsx", ".xls"))
    if not (is_csv or is_excel):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Arquivo deve ser .csv, .xlsx ou .xls",
        )
    suffix = ".csv" if is_csv else ".xlsx"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name

    job_service = JobService()
    job_id = job_service.create_job()
    background_tasks.add_task(
        _process_product_upload_async,
        job_id=job_id,
        file_path=tmp_path,
        file_format="csv" if is_csv else "excel",
        clean_before=clean_before,
    )
    logger.info(f"Import planilha base: job_id={job_id} clean_before={clean_before}")
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content={
            "success": True,
            "job_id": job_id,
            "status": "pending",
            "message": "Importação iniciada em background. A base de dados será atualizada. Use GET /api/product/job/{job_id} para acompanhar.",
            "check_status_url": f"/api/product/job/{job_id}",
        },
    )
