"""Use case for getting coupon by ID"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl
from app.presentation.routers.response.coupon_response import CouponResponse


class GetCouponUseCase(UseCase[Dict[str, Any], CouponResponse]):
    """Use case for getting coupon by ID"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> CouponResponse:
        """Executes the get coupon use case"""
        try:
            coupon_id = request.get('coupon_id')
            if not coupon_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do cupom é obrigatório"
                )

            coupon = self.coupon_repo.get_by_id(coupon_id, session)
            if not coupon:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Cupom com ID {coupon_id} não encontrado"
                )

            return self._build_coupon_response(coupon)

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao buscar cupom: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao buscar cupom: {str(e)}"
            )

    def _build_coupon_response(self, coupon) -> CouponResponse:
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
