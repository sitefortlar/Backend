"""Router para operações de Produtos - Refatorado com Clean Architecture e SOLID"""

import tempfile
import os
import threading
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, status, Query, Path, Body, BackgroundTasks
from fastapi.responses import JSONResponse
from typing import Any, List, Optional
from loguru import logger

from app.application.usecases.impl.list_products_use_case import ListProductsUseCase
from app.application.usecases.impl.get_cart_prices_use_case import GetCartPricesUseCase

# Use Cases
from app.application.usecases.impl.update_products_from_spreadsheet_use_case import UpdateProductsFromSpreadsheetUseCase
from app.application.usecases.impl.update_product_use_case import UpdateProductUseCase
from app.application.usecases.impl.get_product_use_case import GetProductUseCase
from app.application.usecases.impl.add_product_images_use_case import AddProductImagesUseCase
from app.application.usecases.impl.delete_product_images_use_case import DeleteProductImagesUseCase

# Services
from app.application.service.job_service import JobService, JobStatus


# Services
from app.domain.models.enumerations.role_enumerations import RoleEnum

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission

from app.presentation.routers.request.excel_request import (
    BulkCreateResponse
)
from app.presentation.routers.request.product_request import UpdateProductRequest
from app.presentation.routers.request.product_image_request import DeleteProductImagesRequest
from app.presentation.routers.response.product_response import ProductResponse
from app.presentation.routers.response.cart_prices_response import CartPricesResponse
from app.presentation.routers.response.product_image_response import (
    ProductImageResponse,
    DeleteProductImagesResponse,
)

produto_router = APIRouter(
    prefix="/product",
    tags=["Produtos"],
    responses={
        404: {"description": "Product não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)

def _parse_ids_param(ids: List[str]) -> List[int]:
    """
    Aceita ids no formato:
    - ids=1&ids=2&ids=3
    - ids=1,2,3
    - mistura dos dois
    """
    result: List[int] = []
    for raw in ids:
        if raw is None:
            continue
        part = str(raw).strip()
        if not part:
            continue
        for token in part.split(","):
            t = token.strip()
            if not t:
                continue
            result.append(int(t))
    return result


@produto_router.get(
    "/cart/prices",
    summary="Preços do carrinho por estado e prazo",
    description="Recebe ids de produtos, estado e prazo (0/30/60) e retorna o preço de cada item com desconto da região.",
    response_model=CartPricesResponse
)
async def get_cart_prices(
    estado: str = Query(..., description="Estado do usuário (ex: SP, RJ, MG, ES)"),
    prazo: int = Query(..., description="Prazo: 0 (à vista), 30, 60"),
    ids: List[str] = Query(..., description="IDs dos produtos (ex: ids=1&ids=2 ou ids=1,2,3)"),
    session: Session = Depends(get_session)
) -> Any:
    try:
        product_ids = _parse_ids_param(ids)
        if not product_ids:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Informe pelo menos um id de produto")

        # Limite de segurança para evitar URL gigante / abuso
        if len(product_ids) > 1000:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Máximo de 1000 ids por requisição")

        use_case = GetCartPricesUseCase()
        result = use_case.execute(
            {"estado": estado, "prazo": prazo, "product_ids": product_ids},
            session
        )
        return result
    except ValueError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="IDs inválidos (use apenas números)")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao calcular preços do carrinho: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro ao calcular preços do carrinho: {str(e)}")


# Dependency Injection Functions removidas - usando padrão simples


@produto_router.get(
    "",
    summary="Listar produtos",
    description="Lista todos os produtos com filtros opcionais consolidados e preços calculados por estado",
    response_model=List[ProductResponse]
)
async def list_products(
    estado: str = Query(..., description="Estado para cálculo de descontos (ex: SP, MG, ES)"),
    id_category: Optional[int] = Query(None, description="Filtrar por ID da categoria"),
    id_subcategory: Optional[int] = Query(None, description="Filtrar por ID da subcategoria"),
    order_price: Optional[str] = Query(None, description="Ordenar por preço: 'ASC' ou 'DESC'"),
    active_only: bool = Query(True, description="Filtrar apenas produtos ativos"),
    include_kits: bool = Query(True, description="Incluir itens de kits (pode ser mais lento). Use false para acelerar."),
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: Optional[int] = Query(None, ge=1, le=10000, description="Número máximo de registros (sem limite se não informado)"),
    session: Session = Depends(get_session)
) -> List[ProductResponse]:
    """
    Lista produtos com filtros opcionais consolidados e preços calculados por estado.
    
    **Parâmetros obrigatórios:**
    - estado: Estado para cálculo de descontos (MG, ES ou qualquer outro que usará SP)
    
    **Filtros disponíveis:**
    - id_category: filtra por categoria
    - id_category + id_subcategory: filtra por categoria e subcategoria
    - order_price: ordena por preço ('ASC' ou 'DESC')
    
    **Lógica de descontos:**
    - Estados MG e ES: usam os descontos específicos de cada estado
    - Outros estados: usam os descontos de SP
    
    **Campos calculados retornados:**
    - avista: valor_base * (1 - desconto_0)
    - 30_dias: valor_base * (1 - desconto_30)
    - 60_dias: valor_base * (1 - desconto_60)

    **Rota pública**: não exige autenticação.

    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Open/Closed: Extensível via novos filtros sem modificar código existente
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        # Valida order_price
        if order_price and order_price.upper() not in ['ASC', 'DESC']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="order_price deve ser 'ASC' ou 'DESC'"
            )
        
        use_case: ListProductsUseCase = ListProductsUseCase()
        request_data = {
            'estado': estado,
            'id_category': id_category,
            'id_subcategory': id_subcategory,
            'order_price': order_price.upper() if order_price else None,
            'active_only': active_only,
            'include_kits': include_kits,
            'skip': skip,
            'limit': limit
        }
        products_data = use_case.execute(request_data, session)
        return [ProductResponse(**product) for product in products_data]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar produtos: {str(e)}")


@produto_router.get(
    "/{product_id}",
    summary="Buscar produto por ID",
    description="Busca um produto específico pelo ID com preços calculados por estado",
    response_model=ProductResponse
)
async def get_product(
    product_id: int = Path(..., description="ID do produto"),
    estado: str = Query(..., description="Estado para cálculo de descontos (ex: SP, MG, ES)"),
    session: Session = Depends(get_session)
) -> ProductResponse:
    """
    Busca produto por ID com preços calculados por estado.
    
    **Parâmetros obrigatórios:**
    - product_id: ID do produto
    - estado: Estado para cálculo de descontos (MG, ES ou qualquer outro que usará SP)
    
    **Lógica de descontos:**
    - Estados MG e ES: usam os descontos específicos de cada estado
    - Outros estados: usam os descontos de SP
    
    **Campos calculados retornados:**
    - avista: valor_base * (1 - desconto_0)
    - dias_30: valor_base * (1 - desconto_30)
    - dias_60: valor_base * (1 - desconto_60)

    **Rota pública**: não exige autenticação.

    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: GetProductUseCase = GetProductUseCase()
        request_data = {
            'product_id': product_id,
            'estado': estado
        }
        product_data = use_case.execute(request_data, session)
        return ProductResponse(**product_data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar produto: {str(e)}")


@produto_router.put(
    "/{product_id}",
    summary="Atualizar produto (admin)",
    description="Atualiza dados do produto: nome, descrição, preço, categoria, subcategoria, ativo, etc. Apenas campos enviados são alterados.",
    response_model=ProductResponse
)
async def update_product(
    product_id: int = Path(..., description="ID do produto"),
    estado: str = Query("SP", description="Estado para cálculo de preços na resposta (ex: SP, MG, ES)"),
    body: UpdateProductRequest = ...,
    session: Session = Depends(get_session),
    current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """Atualiza um produto. Envie apenas os campos que deseja alterar."""
    try:
        payload = body.model_dump(exclude_none=True)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Envie pelo menos um campo para atualizar"
            )
        UpdateProductUseCase().execute(
            {"product_id": product_id, **payload},
            session
        )
        product_data = GetProductUseCase().execute(
            {"product_id": product_id, "estado": estado},
            session
        )
        return ProductResponse(**product_data)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao atualizar produto: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro ao atualizar produto: {str(e)}")


@produto_router.post(
    "/{product_id}/images",
    summary="Adicionar imagens ao produto (admin)",
    description="Faz upload de uma ou mais imagens para o MinIO e associa ao produto.",
    response_model=List[ProductImageResponse]
)
async def add_product_images(
    product_id: int = Path(..., description="ID do produto"),
    files: List[UploadFile] = File(..., description="Imagens (jpg, png, gif, webp)"),
    session: Session = Depends(get_session),
    current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """Adiciona uma ou mais imagens ao produto. As imagens são enviadas ao MinIO."""
    try:
        uploads = []
        for f in files:
            uploads.append({
                "file_bytes": await f.read(),
                "file_name": f.filename or "image.jpg",
                "content_type": f.content_type or "image/jpeg",
            })
        created = AddProductImagesUseCase().execute(
            {"product_id": product_id, "files": uploads},
            session
        )
        return [
            {"id_imagem": img.id_imagem, "url": img.url, "id_produto": product_id}
            for img in created
        ]
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao adicionar imagens: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro ao adicionar imagens: {str(e)}")


@produto_router.delete(
    "/{product_id}/images",
    summary="Remover imagens do produto (admin)",
    description="Remove uma ou mais imagens do banco e do MinIO.",
    response_model=DeleteProductImagesResponse
)
async def delete_product_images(
    product_id: int = Path(..., description="ID do produto"),
    body: DeleteProductImagesRequest = Body(...),
    session: Session = Depends(get_session),
    current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """Remove uma ou mais imagens do produto."""
    try:
        result = DeleteProductImagesUseCase().execute(
            {"product_id": product_id, "image_ids": body.image_ids},
            session
        )
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao remover imagens: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Erro ao remover imagens: {str(e)}")


def _process_product_upload_async(job_id: str, file_path: str, file_format: str):
    """
    Processa upload de produtos em background
    
    Args:
        job_id: ID do job
        file_path: Caminho do arquivo temporário
        file_format: Formato do arquivo ('csv' ou 'excel')
    """
    job_service = JobService()
    job_service.update_job_status(job_id, JobStatus.PROCESSING, progress=0)
    
    try:
        from app.infrastructure.configs.database_config import Session
        # Cria sessão própria para o thread (usando Session() que é o sessionmaker)
        db_session = Session()
        
        try:
            use_case = UpdateProductsFromSpreadsheetUseCase()
            request = {
                'file_path': file_path,
                'file_format': file_format,
            }
            
            logger.info(
                f"Job {job_id}: Iniciando processamento assíncrono | "
                f"file_format={file_format} | PATCH de nome e valor_base por codigo"
            )
            result = use_case.execute(request, db_session)
            
            # Commit da transação
            db_session.commit()
            
            # Atualiza job com resultado
            job_service.update_job_status(
                job_id,
                JobStatus.COMPLETED,
                progress=100,
                result=result,
                summary=result.get("summary", {})
            )
            
            logger.info(f"Job {job_id}: Processamento concluído com sucesso")
            
        except Exception as e:
            logger.error(f"Job {job_id}: Erro no processamento: {e}", exc_info=True)
            job_service.update_job_status(
                job_id,
                JobStatus.FAILED,
                error=str(e)
            )
            if db_session.is_active:
                db_session.rollback()
        finally:
            db_session.close()
            # Remove arquivo temporário
            if os.path.exists(file_path):
                try:
                    os.unlink(file_path)
                except Exception as e:
                    logger.warning(f"Job {job_id}: Erro ao remover arquivo temporário: {e}")
                    
    except Exception as e:
        logger.error(f"Job {job_id}: Erro crítico: {e}", exc_info=True)
        job_service.update_job_status(
            job_id,
            JobStatus.FAILED,
            error=f"Erro crítico: {str(e)}"
        )


@produto_router.patch(
    "",
    summary="Atualizar produtos por planilha (assíncrono)",
    description="Atualiza somente nome e valor_base dos produtos encontrados pelo codigo.",
    response_model=dict
)
async def patch_products_from_spreadsheet(
        background_tasks: BackgroundTasks,
        file: UploadFile = File(..., description="CSV ou Excel com as colunas codigo, nome e valor_base"),
        current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """
    Atualização parcial de produtos por CSV ou Excel (PROCESSAMENTO ASSÍNCRONO).
    
    **IMPORTANTE**: Este endpoint retorna imediatamente com um `job_id`. Use o endpoint 
    `GET /product/job/{job_id}` para acompanhar o progresso e obter o resultado.

    Formatos suportados:

    A planilha deve ter **exatamente** estas colunas: `codigo`, `nome`, `valor_base`.
    Cada linha procura um produto pelo `codigo` e altera somente `nome` e `valor_base`.
    Códigos inexistentes não criam produtos; são retornados no resumo do job.

    **Resposta:**
    ```json
    {
        "job_id": "uuid-do-job",
        "status": "pending",
        "message": "Processamento iniciado. Use GET /product/job/{job_id} para acompanhar."
    }
    ```
    """
    try:
        # Valida tipo de arquivo
        if not file.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Nome do arquivo é obrigatório"
            )

        # Detecta formato do arquivo
        file_ext = file.filename.lower()
        is_csv = file_ext.endswith('.csv')
        is_excel = file_ext.endswith(('.xlsx', '.xls'))

        if not (is_csv or is_excel):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo deve ser .csv, .xlsx ou .xls"
            )

        # Determina sufixo do arquivo temporário
        suffix = '.csv' if is_csv else ('.xls' if file_ext.endswith('.xls') else '.xlsx')

        # Salva arquivo temporário
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name

        # Cria job assíncrono
        job_service = JobService()
        job_id = job_service.create_job()
        
        # Adiciona task em background
        background_tasks.add_task(
            _process_product_upload_async,
            job_id=job_id,
            file_path=tmp_path,
            file_format='csv' if is_csv else 'excel',
        )
        
        logger.info(
            f"Job {job_id} criado e processamento assíncrono iniciado | "
            f"arquivo={file.filename} | atualização parcial por codigo"
        )
        
        return JSONResponse(
            status_code=status.HTTP_202_ACCEPTED,
            content={
                "success": True,
                "job_id": job_id,
                "status": "pending",
                "message": "Processamento iniciado em background. Use GET /product/job/{job_id} para acompanhar o progresso.",
                "check_status_url": f"/api/product/job/{job_id}"
            }
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao criar job: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao iniciar processamento: {str(e)}"
        )


@produto_router.get(
    "/job/{job_id}",
    summary="Verificar status do job de processamento",
    description="Retorna o status e resultado de um job de processamento assíncrono",
    response_model=dict
)
async def get_job_status(
        job_id: str = Path(..., description="ID do job retornado pelo endpoint de upload"),
        current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """
    Verifica o status de um job de processamento assíncrono.
    
    **Status possíveis:**
    - `pending`: Job criado, aguardando processamento
    - `processing`: Job em processamento
    - `completed`: Job concluído com sucesso
    - `failed`: Job falhou
    
    **Resposta quando concluído:**
    ```json
    {
        "job_id": "uuid",
        "status": "completed",
        "result": {
            "success": true,
            "summary": {
                "produtos_created": 10,
                "imagens_created": 15,
                ...
            }
        }
    }
    ```
    """
    job_service = JobService()
    job = job_service.get_job(job_id)
    
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Job {job_id} não encontrado"
        )
    
    return JSONResponse(
        status_code=status.HTTP_200_OK,
        content=job
    )

