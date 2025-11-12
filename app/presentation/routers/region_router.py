"""Router para operações de Regiões"""

from fastapi import APIRouter, Depends, HTTPException
from loguru import logger

# Use Cases
from app.application.usecases.impl.create_region_use_case import CreateRegionUseCase

# Request/Response Models
from app.presentation.routers.request.region_request import RegionRequest
from app.presentation.routers.response.region_response import RegionResponse

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission
from app.domain.models.enumerations.role_enumerations import RoleEnum

region_router = APIRouter(
    prefix="/region",
    tags=["Regiões"],
    responses={
        404: {"description": "Region não encontrada"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@region_router.post(
    "/",
    response_model=RegionResponse,
    status_code=201,
    summary="Create region",
    description="Creates a new region with discount rates"
)
async def create_region(
    region: RegionRequest,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> RegionResponse:
    """Creates a new region with discount rates"""
    try:
        logger.info('=== Creating region ===')
        use_case: CreateRegionUseCase = CreateRegionUseCase()
        return use_case.execute(region, session=session)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating region: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating region: {str(e)}")

