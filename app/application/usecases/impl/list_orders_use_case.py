"""Use case para listar pedidos"""

from typing import List, Dict, Any, Optional
from datetime import datetime
from decimal import Decimal
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.order_model import Order, OrderStatusEnum
from app.infrastructure.repositories.order_repository_interface import IOrderRepository
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl


class ListOrdersUseCase(UseCase[Dict[str, Any], List[Dict[str, Any]]]):
    """Use case para listar pedidos com filtros"""

    def __init__(self):
        self.pedido_repository: IOrderRepository = OrderRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> List[Dict[str, Any]]:
        """Executa o caso de uso de listagem de pedidos"""
        try:
            skip = request.get('skip', 0)
            limit = request.get('limit', 100)
            cliente_id = request.get('cliente_id')
            status = request.get('status')
            cupom_id = request.get('cupom_id')
            start_date = request.get('start_date')
            end_date = request.get('end_date')
            min_value = request.get('min_value')
            max_value = request.get('max_value')

            # Busca pedidos baseado nos filtros
            pedidos = self._get_pedidos_by_filters(
                session, skip, limit, cliente_id, status, cupom_id,
                start_date, end_date, min_value, max_value
            )

            # Converte para DTOs de resposta
            return [self._build_pedido_response(order) for order in pedidos]

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar pedidos: {str(e)}"
            )

    def _get_pedidos_by_filters(
        self, session, skip: int, limit: int, cliente_id: Optional[int],
        status: Optional[str], cupom_id: Optional[int], start_date: Optional[datetime],
        end_date: Optional[datetime], min_value: Optional[float], max_value: Optional[float]
    ) -> List[Order]:
        """Aplica filtros na busca de pedidos"""
        if cliente_id:
            return self.pedido_repository.get_by_cliente(cliente_id, session)
        elif status:
            try:
                status_enum = OrderStatusEnum(status)
                return self.pedido_repository.get_by_status(status_enum, session)
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                    detail="Status inválido"
                )
        elif cupom_id:
            return self.pedido_repository.get_by_cupom(cupom_id, session)
        elif start_date and end_date:
            return self.pedido_repository.get_by_date_range(start_date, end_date, session)
        elif min_value is not None and max_value is not None:
            return self.pedido_repository.get_orders_by_value_range(
                Decimal(str(min_value)), 
                Decimal(str(max_value)), 
                session
            )
        else:
            return self.pedido_repository.get_all(session, skip, limit)

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
