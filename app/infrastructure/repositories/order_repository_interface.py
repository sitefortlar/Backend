"""Interface do repository para Order"""

from abc import ABC, abstractmethod
from typing import Optional, List
from datetime import datetime

from app.domain.models.order_model import Order
from app.infrastructure.configs.database_config import Session


class IOrderRepository(ABC):
    """Interface para operações de Order"""

    @abstractmethod
    def create(self, order: Order, session: Session) -> Order:
        pass

    @abstractmethod
    def create_order_with_items(self, order: Order, session: Session) -> Order:
        pass

    @abstractmethod
    def get_by_id(self, pedido_id: int, session: Session) -> Optional[Order]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Order]:
        pass

    @abstractmethod
    def update(self, order: Order, session: Session) -> Order:
        pass

    @abstractmethod
    def delete(self, pedido_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_cliente(self, cliente_id: int, session: Session) -> List[Order]:
        pass

    @abstractmethod
    def get_by_status(self, status: str, session: Session) -> List[Order]:
        pass

    @abstractmethod
    def get_by_date_range(self, start_date: datetime, end_date: datetime, session: Session) -> List[Order]:
        pass

    @abstractmethod
    def get_by_cupom(self, cupom_id: int, session: Session) -> List[Order]:
        pass
