"""Use case para listar pedidos recentes"""

from typing import List, Dict, Any
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.order_model import Order
from app.infrastructure.repositories.order_repository_interface import IOrderRepository
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl


class ListRecentOrdersUseCase(UseCase[Dict[str, Any], List[Dict[str, Any]]]):
    """Use case para listar pedidos recentes"""

    def __init__(self):
        self.pedido_repository: IOrderRepository = OrderRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> List[Dict[str, Any]]:
        """Executa o caso de uso de listagem de pedidos recentes"""
        try:
            days = request.get('days', 7)

            if not isinstance(days, int) or days < 1 or days > 365:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Número de dias deve ser entre 1 e 365"
                )

            pedidos = self.pedido_repository.get_recent_orders(days, session)

            return [self._build_pedido_response(order) for order in pedidos]

        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar pedidos recentes: {str(e)}"
            )

    def _build_pedido_response(self, order: Order) -> Dict[str, Any]:
        """Constrói a resposta do order"""
        return {
            "id": order.id_pedido,
            "id_cliente": order.id_cliente,
            "id_cupom": order.id_cupom,
            "data_pedido": order.data_pedido.isoformat(),
            "status": order.status.value if order.status else None,
            "valor_total": float(order.valor_total),
            "created_at": order.created_at.isoformat(),
            "updated_at": order.updated_at.isoformat()
        }
