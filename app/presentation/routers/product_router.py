"""Router para operações de Produtos - Refatorado com Clean Architecture e SOLID"""

import tempfile
import os
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, status, Query, Path
from fastapi.responses import JSONResponse
from typing import Any, List, Optional
from loguru import logger

from app.application.usecases.impl.list_products_use_case import ListProductsUseCase
from app.infrastructure.configs.database_config import Session as DBSession

# Use Cases
from app.application.usecases.impl.create_product_use_case import CreateProductUseCase


# Services
from app.domain.models.enumerations.role_enumerations import RoleEnum

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission

from app.presentation.routers.request.excel_request import (
    BulkCreateResponse
)
from app.presentation.routers.response.product_response import ProductResponse

produto_router = APIRouter(
    prefix="/product",
    tags=["Produtos"],
    responses={
        404: {"description": "Product não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


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
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: Optional[int] = Query(None, ge=1, le=10000, description="Número máximo de registros (sem limite se não informado)"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.CLIENTE))
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
    
    **Autenticação necessária**: Bearer Token JWT
    
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
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.CLIENTE))
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
    
    **Autenticação necessária**: Bearer Token JWT
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        from app.application.usecases.impl.get_product_use_case import GetProductUseCase
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




@produto_router.post(
    "",
    summary="Upload de planilha Excel",
    description="Faz upload de planilha Excel e cria produtos em lote",
    response_model=BulkCreateResponse
)
async def create_product(
        file: UploadFile = File(..., description="Arquivo CSV ou Excel com estrutura completa"),
        session: DBSession = Depends(get_session),
        current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """
    Upload de planilha CSV ou Excel completa para população da base de dados.

    Formatos suportados:

    **CSV:**
    - codigo, id_categoria, id_subcategoria, Nome, Quantidade, Descricao, Codigo Amarração, Vlr Bruto, Vlr Unitario
    - Preços por região/prazo: Vista SP, 30 dias SP, 60 dias SP, Vista MG, 30 dias MG, 60 dias MG, Vista ES, 30 dias ES, 60 dias ES

    **Excel:**
    - PRODUTO, CATEGORIA, SUBCATEGORIA, DESCRIÇÃO, REGIÃO, PRAZO DE ENTREGA, VALOR UNITÁRIO, KIT, OBSERVAÇÕES

    O sistema detecta automaticamente o formato e processa adequadamente.

    O sistema irá:
    1. Criar categorias e subcategorias automaticamente se não existirem
    2. Criar regiões e prazos de pagamento se não existirem
    3. Criar ou atualizar produtos (busca por código ou nome)
    4. Criar kits e associar produtos baseado na coluna KIT ou Código Amarração
    5. Criar preços por região/prazo (formato CSV)
    6. Retornar um resumo com contadores de entidades criadas/atualizadas

    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra o upload
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    - Open/Closed: Extensível para novos formatos sem modificar código existente
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
        suffix = '.csv' if is_csv else '.xlsx'

        # Salva arquivo temporário
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name

        try:
            # Executa use case
            use_case = CreateProductUseCase()
            request = {
                'file_path': tmp_path,
                'file_format': 'csv' if is_csv else 'excel'
            }
            result = use_case.execute(request, session)

            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content=result
            )
        except HTTPException:
            raise
        except Exception as e:
            # Transação já foi revertida no use case
            logger.error(f"Erro no processamento: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro no processamento: {str(e)}"
            )
        finally:
            # Remove arquivo temporário
            if os.path.exists(tmp_path):
                try:
                    os.unlink(tmp_path)
                except Exception:
                    pass

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro no upload: {str(e)}"
        )


@produto_router.put(
    "",
    summary="Atualização completa de planilha Excel (limpa e recria tudo)",
    description="Faz upload de planilha Excel e recria todos os produtos do zero. "
                "**ATENÇÃO**: Este endpoint apaga TODOS os produtos, imagens do banco e imagens do Supabase antes de processar.",
    response_model=BulkCreateResponse
)
async def update_all_products(
        file: UploadFile = File(..., description="Arquivo CSV ou Excel com estrutura completa"),
        session: DBSession = Depends(get_session),
        current_user=Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> Any:
    """
    Upload de planilha CSV ou Excel com limpeza completa antes de processar.
    
    **IMPORTANTE**: Este endpoint:
    1. Apaga TODOS os produtos do banco de dados
    2. Apaga TODAS as imagens de produtos do banco
    3. Apaga TODAS as imagens do Supabase Storage (pasta produtos/)
    4. Processa a planilha e cria tudo novamente
    
    Formatos suportados são os mesmos do POST:
    
    **CSV:**
    - codigo, id_categoria, id_subcategoria, Nome, Quantidade, Descricao, Codigo Amarração, Vlr Bruto, Vlr Unitario
    - Preços por região/prazo: Vista SP, 30 dias SP, 60 dias SP, Vista MG, 30 dias MG, 60 dias MG, Vista ES, 30 dias ES, 60 dias ES
    
    **Excel:**
    - PRODUTO, CATEGORIA, SUBCATEGORIA, DESCRIÇÃO, REGIÃO, PRAZO DE ENTREGA, VALOR UNITÁRIO, KIT, OBSERVAÇÕES
    
    Use este endpoint quando quiser fazer uma atualização completa do catálogo.
    """
    try:
        # Valida tipo de arquivo (mesma lógica do POST)
        if not file.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Nome do arquivo é obrigatório"
            )

        file_ext = file.filename.lower()
        is_csv = file_ext.endswith('.csv')
        is_excel = file_ext.endswith(('.xlsx', '.xls'))

        if not (is_csv or is_excel):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo deve ser .csv, .xlsx ou .xls"
            )

        suffix = '.csv' if is_csv else '.xlsx'

        # Salva arquivo temporário
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name

        try:
            logger.info("Executando PUT: Limpeza completa e reprocessamento")
            
            # Executa use case com flag clean_before=True
            use_case = CreateProductUseCase()
            request = {
                'file_path': tmp_path,
                'file_format': 'csv' if is_csv else 'excel',
                'clean_before': True  # Flag para limpar tudo antes
            }
            result = use_case.execute(request, session)

            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content=result
            )
        except HTTPException:
            raise
        except Exception as e:
            # Transação já foi revertida no use case
            logger.error(f"Erro no processamento: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro no processamento: {str(e)}"
            )
        finally:
            # Remove arquivo temporário
            if os.path.exists(tmp_path):
                try:
                    os.unlink(tmp_path)
                except Exception:
                    pass

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro no upload: {str(e)}"
        )


