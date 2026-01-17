"""Use case for listing coupons"""

from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.coupon_model import Coupon
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl
from app.presentation.routers.response.coupon_response import CouponResponse


class ListCouponsUseCase(UseCase[Dict[str, Any], List[CouponResponse]]):
    """Use case for listing coupons"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> List[CouponResponse]:
        """Executes the coupon listing use case"""
        try:
            skip = request.get('skip', 0)
            limit = request.get('limit', 100)
            active_only = request.get('active_only', False)
            search_codigo = request.get('search_codigo')

            # Busca cupons baseado nos filtros
            if active_only:
                coupons = self.coupon_repo.get_active_coupons(session, skip, limit)
            elif search_codigo:
                # Busca por código (case insensitive)
                coupon = self.coupon_repo.get_by_codigo(search_codigo.upper().strip(), session)
                coupons = [coupon] if coupon else []
            else:
                coupons = self.coupon_repo.get_all(session, skip, limit)

            # Converte para DTOs de resposta
            return [self._build_coupon_response(coupon) for coupon in coupons]

        except Exception as e:
            logger.error(f"Erro ao listar cupons: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar cupons: {str(e)}"
            )

    def _build_coupon_response(self, coupon: Coupon) -> CouponResponse:
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
