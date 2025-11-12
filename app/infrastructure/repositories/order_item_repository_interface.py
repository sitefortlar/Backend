from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.order_item_model import OrderItem
from app.infrastructure.configs.database_config import Session


class IItemOrderRepository(ABC):
    """Interface para operações de ItemOrder"""

    @abstractmethod
    def create(self, item_pedido: OrderItem, session: Session) -> OrderItem:
        """Cria um novo item de order"""
        pass

    @abstractmethod
    def get_by_id(self, item_id: int, session: Session) -> Optional[OrderItem]:
        """Busca item de order por ID"""
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[OrderItem]:
        """Lista todos os itens de order"""
        pass

    @abstractmethod
    def update(self, item_pedido: OrderItem, session: Session) -> OrderItem:
        """Atualiza um item de order"""
        pass

    @abstractmethod
    def delete(self, item_id: int, session: Session) -> bool:
        """Deleta um item de order"""
        pass

    @abstractmethod
    def get_by_pedido_id(self, pedido_id: int, session: Session) -> List[OrderItem]:
        """Busca itens por ID do order"""
        pass

    @abstractmethod
    def get_by_produto_id(self, produto_id: int, session: Session) -> List[OrderItem]:
        """Busca itens por ID do produto"""
        pass

    @abstractmethod
    def get_total_by_pedido(self, pedido_id: int, session: Session) -> float:
        """Calcula total dos itens de um order"""
        pass

    @abstractmethod
    def get_quantity_by_produto(self, produto_id: int, session: Session) -> int:
        """Calcula quantidade total vendida de um produto"""
        pass
