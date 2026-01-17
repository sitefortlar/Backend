"""Use case for validating coupon by code"""

from typing import Dict, Any
from datetime import date
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl
from app.presentation.routers.response.coupon_response import ValidateCouponResponse, CouponResponse


class ValidateCouponUseCase(UseCase[Dict[str, Any], ValidateCouponResponse]):
    """Use case for validating coupon by code"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> ValidateCouponResponse:
        """Executes the coupon validation use case"""
        try:
            codigo = request.get('codigo')
            if not codigo:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Código do cupom é obrigatório"
                )

            coupon = self.coupon_repo.get_by_codigo(codigo.upper().strip(), session)
            
            if not coupon:
                return ValidateCouponResponse(
                    valid=False,
                    coupon=None,
                    message="Cupom não encontrado"
                )

            # Valida se está ativo
            if not coupon.ativo:
                return ValidateCouponResponse(
                    valid=False,
                    coupon=self._build_coupon_response(coupon),
                    message="Cupom está inativo"
                )

            # Valida datas de validade
            today = date.today()
            if coupon.validade_inicio and today < coupon.validade_inicio:
                return ValidateCouponResponse(
                    valid=False,
                    coupon=self._build_coupon_response(coupon),
                    message=f"Cupom ainda não está válido. Válido a partir de {coupon.validade_inicio}"
                )

            if coupon.validade_fim and today > coupon.validade_fim:
                return ValidateCouponResponse(
                    valid=False,
                    coupon=self._build_coupon_response(coupon),
                    message=f"Cupom expirado. Válido até {coupon.validade_fim}"
                )

            return ValidateCouponResponse(
                valid=True,
                coupon=self._build_coupon_response(coupon),
                message="Cupom válido"
            )

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao validar cupom: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao validar cupom: {str(e)}"
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
