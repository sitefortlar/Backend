"""Implementação do repository para Order"""

from typing import Optional, List
from datetime import datetime
from decimal import Decimal

from app.domain.models.order_model import Order, OrderStatusEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.order_repository_interface import IOrderRepository


class OrderRepositoryImpl(IOrderRepository):
    """Repository para operações de Order com CRUD completo"""

    # Implementação dos métodos abstratos do IOrderRepository
    def create(self, order: Order, session: Session) -> Order:
        """Cria um novo order"""
        session.add(order)
        session.flush()
        return order

    def create_order_with_items(self, order: Order, session: Session) -> Order:
        """Cria um order com seus itens (os itens devem estar associados ao order antes)"""
        session.add(order)
        session.flush()
        return order

    def get_by_id(self, pedido_id: int, session: Session) -> Optional[Order]:
        """Busca order por ID"""
        return session.query(Order).filter(Order.id_pedido == pedido_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Order]:
        """Lista todos os pedidos"""
        return session.query(Order).offset(skip).limit(limit).all()

    def update(self, order: Order, session: Session) -> Order:
        """Atualiza um order"""
        session.merge(order)
        session.flush()
        return order

    def delete(self, pedido_id: int, session: Session) -> bool:
        """Deleta um order"""
        order = self.get_by_id(pedido_id, session)
        if order:
            session.delete(order)
            session.flush()
            return True
        return False

    def get_by_cliente(self, cliente_id: int, session: Session) -> List[Order]:
        """Busca pedidos por cliente"""
        return session.query(Order).filter(Order.id_cliente == cliente_id).all()

    def get_by_status(self, status: OrderStatusEnum, session: Session) -> List[Order]:
        """Busca pedidos por status"""
        return session.query(Order).filter(Order.status == status).all()

    def get_by_date_range(self, start_date: datetime, end_date: datetime, session: Session) -> List[Order]:
        """Busca pedidos por intervalo de datas"""
        return session.query(Order).filter(
            Order.created_at.between(start_date, end_date)
        ).all()

    def get_by_cupom(self, cupom_id: int, session: Session) -> List[Order]:
        """Busca pedidos por cupom"""
        return session.query(Order).filter(Order.id_cupom == cupom_id).all()

    def get_pending_orders(self, session: Session) -> List[Order]:
        """Busca pedidos pendentes"""
        return session.query(Order).filter(
            Order.status == OrderStatusEnum.PENDENTE
        ).all()

    def get_orders_by_value_range(self, min_value: Decimal, max_value: Decimal, session: Session) -> List[Order]:
        """Busca pedidos por faixa de valor"""
        return session.query(Order).filter(
            Order.valor_total.between(min_value, max_value)
        ).all()

    def get_recent_orders(self, days: int, session: Session) -> List[Order]:
        """Busca pedidos recentes (últimos X dias)"""
        from datetime import timedelta
        start_date = datetime.now() - timedelta(days=days)
        return session.query(Order).filter(
            Order.created_at >= start_date
        ).all()

    def update_status(self, pedido_id: int, status: OrderStatusEnum, session: Session) -> bool:
        """Atualiza status do order"""
        order = self.get_by_id(pedido_id, session)
        if order:
            order.status = status
            session.flush()
            return True
        return False

    def get_orders_with_items(self, pedido_id: int, session: Session) -> Optional[Order]:
        """Busca order com itens"""
        from sqlalchemy.orm import joinedload
        return session.query(Order).options(
            joinedload(Order.itens)
        ).filter(Order.id_pedido == pedido_id).first()
