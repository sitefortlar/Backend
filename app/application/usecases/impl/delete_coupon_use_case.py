"""Use case for deleting coupon"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository
from app.infrastructure.repositories.impl.coupon_repository_impl import CouponRepositoryImpl


class DeleteCouponUseCase(UseCase[Dict[str, Any], bool]):
    """Use case for deleting coupon"""

    def __init__(self):
        self.coupon_repo: ICouponRepository = CouponRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> bool:
        """Executes the coupon deletion use case"""
        try:
            coupon_id = request.get('coupon_id')
            if not coupon_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do cupom é obrigatório"
                )

            # Verifica se cupom existe
            coupon = self.coupon_repo.get_by_id(coupon_id, session)
            if not coupon:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Cupom com ID {coupon_id} não encontrado"
                )

            # Deleta cupom
            deleted = self.coupon_repo.delete(coupon_id, session)
            if deleted:
                logger.info(f"Coupon deleted: {coupon_id}")
                return True
            else:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Erro ao deletar cupom"
                )

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao deletar cupom: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao deletar cupom: {str(e)}"
            )
