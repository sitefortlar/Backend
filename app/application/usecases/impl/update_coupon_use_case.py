"""Use case for updating coupon"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.coupon_model import Coupon
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl
from app.presentation.routers.response.coupon_response import CouponResponse


class UpdateCouponUseCase(UseCase[Dict[str, Any], CouponResponse]):
    """Use case for updating coupon"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> CouponResponse:
        """Executes the coupon update use case"""
        try:
            coupon_id = request.get('coupon_id')
            if not coupon_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do cupom é obrigatório"
                )

            # Busca cupom existente
            coupon = self.coupon_repo.get_by_id(coupon_id, session)
            if not coupon:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Cupom com ID {coupon_id} não encontrado"
                )

            # Atualiza campos permitidos
            self._update_coupon_fields(coupon, request)

            # Validações
            self._validate_update(coupon, request, session)

            # Salva alterações
            updated_coupon = self.coupon_repo.update(coupon, session)
            logger.info(f"Coupon updated: {updated_coupon.id_cupom} - {updated_coupon.codigo}")

            return self._build_coupon_response(updated_coupon)

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao atualizar cupom: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao atualizar cupom: {str(e)}"
            )

    def _update_coupon_fields(self, coupon: Coupon, request: Dict[str, Any]) -> None:
        """Atualiza campos do cupom"""
        if 'codigo' in request and request['codigo']:
            coupon.codigo = request['codigo'].upper().strip()
        if 'tipo' in request and request['tipo']:
            coupon.tipo = request['tipo']
        if 'valor' in request and request['valor'] is not None:
            coupon.valor = request['valor']
        if 'validade_inicio' in request:
            coupon.validade_inicio = request['validade_inicio']
        if 'validade_fim' in request:
            coupon.validade_fim = request['validade_fim']
        if 'ativo' in request and request['ativo'] is not None:
            coupon.ativo = request['ativo']

    def _validate_update(self, coupon: Coupon, request: Dict[str, Any], session) -> None:
        """Valida atualização do cupom"""
        # Valida código único (se foi alterado)
        if 'codigo' in request and request['codigo']:
            new_codigo = request['codigo'].upper().strip()
            if new_codigo != coupon.codigo:
                if self.coupon_repo.exists_by_codigo(new_codigo, session):
                    raise HTTPException(
                        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                        detail=f"Cupom com código '{new_codigo}' já existe"
                    )
        
        # Valida datas
        validade_inicio = request.get('validade_inicio', coupon.validade_inicio)
        validade_fim = request.get('validade_fim', coupon.validade_fim)
        
        if validade_inicio and validade_fim:
            if validade_inicio > validade_fim:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Data de início não pode ser maior que data de fim"
                )
        
        # Valida valor para percentual
        tipo = request.get('tipo', coupon.tipo)
        valor = request.get('valor', coupon.valor)
        
        if tipo and tipo.value == 'percentual' and valor and valor > 100:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Valor percentual não pode ser maior que 100"
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
