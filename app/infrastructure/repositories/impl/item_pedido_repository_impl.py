from typing import Optional, List
from decimal import Decimal

from app.domain.models.order_item_model import OrderItem
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.order_item_repository_interface import IItemOrderRepository


class ItemOrderRepositoryImpl(IItemOrderRepository):
    """Repository para operações de ItemOrder com CRUD completo"""

    def create(self, item_pedido: OrderItem, session: Session) -> OrderItem:
        """Cria um novo item de order"""
        session.add(item_pedido)
        session.flush()
        return item_pedido

    def get_by_id(self, item_id: int, session: Session) -> Optional[OrderItem]:
        """Busca item de order por ID"""
        return session.query(OrderItem).filter(OrderItem.id_item == item_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[OrderItem]:
        """Lista todos os itens de order"""
        return session.query(OrderItem).offset(skip).limit(limit).all()

    def update(self, item_pedido: OrderItem, session: Session) -> OrderItem:
        """Atualiza um item de order"""
        session.merge(item_pedido)
        session.flush()
        return item_pedido

    def delete(self, item_id: int, session: Session) -> bool:
        """Deleta um item de order"""
        item = self.get_by_id(item_id, session)
        if item:
            session.delete(item)
            session.flush()
            return True
        return False

    def get_by_pedido_id(self, pedido_id: int, session: Session) -> List[OrderItem]:
        """Busca itens por ID do order"""
        return session.query(OrderItem).filter(OrderItem.id_pedido == pedido_id).all()

    def get_by_produto_id(self, produto_id: int, session: Session) -> List[OrderItem]:
        """Busca itens por ID do produto"""
        return session.query(OrderItem).filter(OrderItem.id_produto == produto_id).all()

    def get_total_by_pedido(self, pedido_id: int, session: Session) -> float:
        """Calcula total dos itens de um order"""
        from sqlalchemy import func
        result = session.query(func.sum(OrderItem.subtotal)).filter(
            OrderItem.id_pedido == pedido_id
        ).scalar()
        return float(result) if result else 0.0

    def get_quantity_by_produto(self, produto_id: int, session: Session) -> int:
        """Calcula quantidade total vendida de um produto"""
        from sqlalchemy import func
        result = session.query(func.sum(OrderItem.quantidade)).filter(
            OrderItem.id_produto == produto_id
        ).scalar()
        return int(result) if result else 0
