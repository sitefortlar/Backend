"""Use case for creating coupon"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.coupon_model import Coupon
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl
from app.presentation.routers.request.coupon_request import CouponRequest
from app.presentation.routers.response.coupon_response import CouponResponse


def _build_coupon_response(coupon: Coupon) -> CouponResponse:
    """Builds the coupon response"""
    return CouponResponse(
        id_cupom=coupon.id_cupom,
        codigo=coupon.codigo,
        tipo=coupon.tipo,
        valor=coupon.valor,
        validade_inicio=coupon.validade_inicio,
        validade_fim=coupon.validade_fim,
        ativo=coupon.ativo,
        created_at=coupon.created_at,
        updated_at=coupon.updated_at
    )


class CreateCouponUseCase(UseCase[CouponRequest, CouponResponse]):
    """Use case for creating coupon"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: CouponRequest, session=None) -> CouponResponse:
        """Executes the coupon creation use case"""
        self._validate_request(request, session)

        # Create coupon entity
        coupon = Coupon(
            codigo=request.codigo.upper().strip(),
            tipo=request.tipo,
            valor=request.valor,
            validade_inicio=request.validade_inicio,
            validade_fim=request.validade_fim,
            ativo=request.ativo
        )
        coupon = self.coupon_repo.create(coupon, session)
        logger.info(f"Coupon created: {coupon.id_cupom} - {coupon.codigo}")

        # Return response
        return _build_coupon_response(coupon)

    def _validate_request(self, request: CouponRequest, session) -> None:
        """Validates the request data"""
        if self.coupon_repo.exists_by_codigo(request.codigo.upper().strip(), session=session):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Cupom com código '{request.codigo}' já existe"
            )
        
        # Valida datas
        if request.validade_inicio and request.validade_fim:
            if request.validade_inicio > request.validade_fim:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Data de início não pode ser maior que data de fim"
                )
        
        # Valida valor para percentual
        if request.tipo.value == 'percentual' and request.valor > 100:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Valor percentual não pode ser maior que 100"
            )
