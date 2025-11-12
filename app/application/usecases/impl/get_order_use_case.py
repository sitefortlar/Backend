"""Use case para buscar order por ID"""

from typing import Dict, Any, Optional
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.order_model import Order
from app.infrastructure.repositories.order_repository_interface import IOrderRepository
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl


class GetOrderUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Use case para buscar order por ID"""

    def __init__(self):
        self.pedido_repository: IOrderRepository = OrderRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        """Executa o caso de uso de busca de order"""
        try:
            pedido_id = request.get('pedido_id')
            include_items = request.get('include_items', False)

            if not pedido_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do order é obrigatório"
                )

            # Busca o order
            if include_items:
                order = self.pedido_repository.get_orders_with_items(pedido_id, session)
            else:
                order = self.pedido_repository.get_by_id(pedido_id, session)

            if not order:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Order não encontrado"
                )

            return self._build_pedido_response(order, include_items)

        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao buscar order: {str(e)}"
            )

    def _build_pedido_response(self, order: Order, include_items: bool = False) -> Dict[str, Any]:
        """Constrói a resposta do order"""
        result = {
            "id": order.id_pedido,
            "id_cliente": order.id_cliente,
            "id_cupom": order.id_cupom,
            "data_pedido": order.data_pedido.isoformat(),
            "status": order.status.value if order.status else None,
            "valor_total": float(order.valor_total),
            "created_at": order.created_at.isoformat(),
            "updated_at": order.updated_at.isoformat()
        }

        if include_items and hasattr(order, 'itens'):
            result["itens"] = [
                {
                    "id": item.id_item,
                    "id_produto": item.id_produto,
                    "quantidade": item.quantidade,
                    "preco_unitario": float(item.preco_unitario),
                    "subtotal": float(item.subtotal)
                }
                for item in order.itens
            ]

        return result
