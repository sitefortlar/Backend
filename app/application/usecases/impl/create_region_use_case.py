"""Use case for creating region"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.regions_model import Regions
from app.infrastructure.repositories.region_repository_interface import IRegionRepository
from app.infrastructure.repositories.impl.region_repository_impl import RegionRepositoryImpl
from app.presentation.routers.request.region_request import RegionRequest
from app.presentation.routers.response.region_response import RegionResponse


def _build_region_response(region: Regions) -> RegionResponse:
    """Builds the region response"""
    return RegionResponse(
        id=region.id_regiao,
        estado=region.estado,
        desconto_0=region.desconto_0,
        desconto_30=region.desconto_30,
        desconto_60=region.desconto_60,
        created_at=region.created_at,
        updated_at=region.updated_at
    )


class CreateRegionUseCase(UseCase[RegionRequest, RegionResponse]):
    """Use case for creating region"""

    def __init__(self):
        self.region_repo: IRegionRepository = RegionRepositoryImpl()

    def execute(self, request: RegionRequest, session=None) -> RegionResponse:
        """Executes the region creation use case"""
        self._validate_request(request, session)

        # Create region entity
        region = Regions(
            estado=request.estado,
            desconto_0=request.desconto_0,
            desconto_30=request.desconto_30,
            desconto_60=request.desconto_60
        )
        region = self.region_repo.create(region, session)
        logger.info(f"Region created: {region.id_regiao} - {region.estado}")

        # Return response
        return _build_region_response(region)

    def _validate_request(self, request: RegionRequest, session) -> None:
        """Validates the request data"""
        if self.region_repo.exists_by_estado(request.estado, session=session):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Region with estado '{request.estado}' already exists"
            )

