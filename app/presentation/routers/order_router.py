"""Router para operações de Orders - Refatorado com Clean Architecture e SOLID"""

from fastapi import APIRouter, Depends, HTTPException, Query, Path
from fastapi.responses import JSONResponse
from typing import List
from loguru import logger

# Use Cases
from app.application.usecases.impl.list_orders_use_case import ListOrdersUseCase
from app.application.usecases.impl.get_order_use_case import GetOrderUseCase
from app.application.usecases.impl.list_recent_orders_use_case import ListRecentOrdersUseCase
from app.application.usecases.impl.send_order_email_use_case import SendOrderEmailUseCase

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission
from app.presentation.routers.request.order_request import (
    ListOrdersRequest,
    GetOrderRequest,
    ListOrdersByClienteRequest,
    ListOrdersByStatusRequest,
    ListOrdersRecentesRequest,
    SendOrderEmailRequest
)
from app.presentation.routers.response.order_response import (
    OrderResponse,
    ListOrdersResponse
)

order_router = APIRouter(
    prefix="/orders",
    tags=["Orders"],
    responses={
        404: {"description": "Order não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@order_router.get(
    "/",
    summary="Listar orders",
    description="Lista todos os orders com filtros opcionais",
    response_model=List[OrderResponse]
)
async def list_orders(
    request: ListOrdersRequest = Depends(),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission())
) -> List[OrderResponse]:
    """
    Lista orders com filtros opcionais.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Open/Closed: Extensível via novos filtros sem modificar código existente
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ListOrdersUseCase = ListOrdersUseCase()
        orders_data = use_case.execute(request.dict(), session)
        return [OrderResponse(**order) for order in orders_data]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar orders: {str(e)}")


@order_router.get(
    "/{order_id}",
    summary="Buscar order por ID",
    description="Busca um order específico pelo ID",
    response_model=OrderResponse
)
async def get_order(
    order_id: int = Path(..., description="ID do order"),
    include_items: bool = Query(False, description="Incluir itens do order"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission())
) -> OrderResponse:
    """
    Busca order por ID.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: GetOrderUseCase = GetOrderUseCase()
        # Mapeia order_id para pedido_id (o use case ainda espera pedido_id)
        request_dict = {"pedido_id": order_id, "include_items": include_items}
        order_data = use_case.execute(request_dict, session)
        return OrderResponse(**order_data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar order: {str(e)}")


@order_router.get(
    "/cliente/{cliente_id}",
    summary="Listar orders do cliente",
    description="Lista todos os orders de um cliente específico",
    response_model=List[OrderResponse]
)
async def list_orders_by_cliente(
    cliente_id: int = Path(..., description="ID do cliente"),
    session: Session = Depends(get_session)
) -> List[OrderResponse]:
    """
    Lista orders de um cliente específico.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ListOrdersUseCase = ListOrdersUseCase()
        request = ListOrdersByClienteRequest(cliente_id=cliente_id)
        orders_data = use_case.execute(request.dict(), session)
        return [OrderResponse(**order) for order in orders_data]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar orders do cliente: {str(e)}")


@order_router.get(
    "/status/{status}",
    summary="Listar orders por status",
    description="Lista orders com um status específico",
    response_model=List[OrderResponse]
)
async def list_orders_by_status(
    status: str = Path(..., description="Status do order"),
    session: Session = Depends(get_session)
) -> List[OrderResponse]:
    """
    Lista orders por status.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ListOrdersUseCase = ListOrdersUseCase()
        request = ListOrdersByStatusRequest(status=status)
        orders_data = use_case.execute(request.dict(), session)
        return [OrderResponse(**order) for order in orders_data]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar orders por status: {str(e)}")


@order_router.get(
    "/recentes",
    summary="Listar orders recentes",
    description="Lista orders dos últimos X dias",
    response_model=List[OrderResponse]
)
async def list_orders_recentes(
    days: int = Query(7, ge=1, le=365, description="Número de dias"),
    session: Session = Depends(get_session)
) -> List[OrderResponse]:
    """
    Lista orders recentes.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ListRecentOrdersUseCase = ListRecentOrdersUseCase()
        request = ListOrdersRecentesRequest(days=days)
        orders_data = use_case.execute(request.dict(), session)
        return [OrderResponse(**order) for order in orders_data]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar orders recentes: {str(e)}")


@order_router.post(
    "/send-email",
    summary="Enviar order por email",
    description="Recebe o carrinho com itens simplificados (valores já calculados) e envia um email formatado em HTML para a empresa com os detalhes do order, incluindo endereço e contato do cliente",
    response_class=JSONResponse
)
async def send_order_email(
    request: SendOrderEmailRequest,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission())
):
    """
    Envia order por email com informações completas do cliente.
    
    Recebe o carrinho com array de itens simplificados (valores já calculados pelo frontend),
    busca informações da empresa (endereço, contato), gera HTML formatado
    e envia por email para a empresa.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: SendOrderEmailUseCase = SendOrderEmailUseCase()
        
        # Converte request do router para request do use case
        from app.domain.models.dtos.send_order_email_dto import (
            SendOrderEmailUseCaseRequest,
            OrderItemUseCaseRequest
        )
        
        # Importa o enum do DTO do use case
        from app.domain.models.dtos.send_order_email_dto import FormaPagamentoEnum as UseCaseFormaPagamentoEnum
        
        use_case_request = SendOrderEmailUseCaseRequest(
            company_id=request.company_id,
            forma_pagamento=UseCaseFormaPagamentoEnum(request.forma_pagamento.value),
            itens=[
                OrderItemUseCaseRequest(
                    id_produto=item.id_produto,
                    codigo=item.codigo,
                    nome=item.nome,
                    quantidade_pedida=item.quantidade_pedida,
                    valor_unitario=item.valor_unitario,
                    valor_total=item.valor_total,
                    categoria=item.categoria,
                    subcategoria=item.subcategoria
                )
                for item in request.itens
            ]
        )
        
        result = use_case.execute(use_case_request, session)
        
        return JSONResponse(
            status_code=200,
            content=result.dict()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Erro ao enviar order por email: {e}")
        raise HTTPException(
            status_code=500, 
            detail=f"Erro ao enviar order por email: {str(e)}"
        )

