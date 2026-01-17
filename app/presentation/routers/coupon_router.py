"""Router para operações de Cupons"""

from fastapi import APIRouter, Depends, HTTPException, Query, Path
from typing import List, Optional
from loguru import logger

# Use Cases
from app.application.usecases.impl.create_coupon_use_case import CreateCouponUseCase
from app.application.usecases.impl.list_coupons_use_case import ListCouponsUseCase
from app.application.usecases.impl.get_coupon_use_case import GetCouponUseCase
from app.application.usecases.impl.validate_coupon_use_case import ValidateCouponUseCase
from app.application.usecases.impl.update_coupon_use_case import UpdateCouponUseCase
from app.application.usecases.impl.delete_coupon_use_case import DeleteCouponUseCase

# Request/Response Models
from app.presentation.routers.request.coupon_request import CouponRequest, UpdateCouponRequest
from app.presentation.routers.response.coupon_response import CouponResponse, ValidateCouponResponse

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission
from app.domain.models.enumerations.role_enumerations import RoleEnum

coupon_router = APIRouter(
    prefix="/coupons",
    tags=["Cupons"],
    responses={
        404: {"description": "Cupom não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@coupon_router.post(
    "",
    response_model=CouponResponse,
    status_code=201,
    summary="Criar cupom",
    description="Cria um novo cupom de desconto"
)
async def create_coupon(
    coupon: CouponRequest,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> CouponResponse:
    """Cria um novo cupom"""
    try:
        logger.info('=== Creating coupon ===')
        use_case: CreateCouponUseCase = CreateCouponUseCase()
        return use_case.execute(coupon, session=session)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating coupon: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating coupon: {str(e)}")


@coupon_router.get(
    "",
    summary="Listar cupons",
    description="Lista todos os cupons com filtros opcionais",
    response_model=List[CouponResponse]
)
async def list_coupons(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros"),
    active_only: bool = Query(False, description="Filtrar apenas cupons ativos"),
    search_codigo: Optional[str] = Query(None, description="Buscar por código do cupom"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> List[CouponResponse]:
    """Lista cupons com filtros opcionais"""
    try:
        use_case: ListCouponsUseCase = ListCouponsUseCase()
        request_dict = {
            'skip': skip,
            'limit': limit,
            'active_only': active_only,
            'search_codigo': search_codigo
        }
        return use_case.execute(request_dict, session)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar cupons: {str(e)}")


@coupon_router.get(
    "/{coupon_id}",
    summary="Buscar cupom por ID",
    description="Busca um cupom específico pelo ID",
    response_model=CouponResponse
)
async def get_coupon(
    coupon_id: int = Path(..., description="ID do cupom"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> CouponResponse:
    """Busca cupom por ID"""
    try:
        use_case: GetCouponUseCase = GetCouponUseCase()
        request_dict = {'coupon_id': coupon_id}
        return use_case.execute(request_dict, session)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar cupom: {str(e)}")


@coupon_router.get(
    "/code/{codigo}",
    summary="Validar cupom por código",
    description="Valida um cupom pelo código e retorna se está válido, ativo e dentro da validade",
    response_model=ValidateCouponResponse
)
async def validate_coupon(
    codigo: str = Path(..., description="Código do cupom"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.CLIENTE))
) -> ValidateCouponResponse:
    """Valida cupom por código - disponível para clientes"""
    try:
        use_case: ValidateCouponUseCase = ValidateCouponUseCase()
        request_dict = {'codigo': codigo}
        return use_case.execute(request_dict, session)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao validar cupom: {str(e)}")


@coupon_router.put(
    "/{coupon_id}",
    summary="Atualizar cupom",
    description="Atualiza um cupom existente",
    response_model=CouponResponse
)
async def update_coupon(
    coupon_id: int = Path(..., description="ID do cupom"),
    coupon: UpdateCouponRequest = ...,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> CouponResponse:
    """Atualiza cupom"""
    try:
        use_case: UpdateCouponUseCase = UpdateCouponUseCase()
        request_dict = {
            'coupon_id': coupon_id,
            **coupon.model_dump(exclude_unset=True)
        }
        return use_case.execute(request_dict, session)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao atualizar cupom: {str(e)}")


@coupon_router.delete(
    "/{coupon_id}",
    summary="Deletar cupom",
    description="Deleta um cupom existente",
    status_code=204
)
async def delete_coupon(
    coupon_id: int = Path(..., description="ID do cupom"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
):
    """Deleta cupom"""
    try:
        use_case: DeleteCouponUseCase = DeleteCouponUseCase()
        request_dict = {'coupon_id': coupon_id}
        use_case.execute(request_dict, session)
        return None
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao deletar cupom: {str(e)}")
