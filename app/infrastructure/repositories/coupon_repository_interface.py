"""Interface do repository para Coupon"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.coupon_model import Coupon
from app.infrastructure.configs.database_config import Session


class ICouponRepository(ABC):
    """Interface para operações de Coupon"""

    @abstractmethod
    def create(self, coupon: Coupon, session: Session) -> Coupon:
        pass

    @abstractmethod
    def get_by_id(self, coupon_id: int, session: Session) -> Optional[Coupon]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Coupon]:
        pass

    @abstractmethod
    def update(self, coupon: Coupon, session: Session) -> Coupon:
        pass

    @abstractmethod
    def delete(self, coupon_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_codigo(self, codigo: str, session: Session) -> Optional[Coupon]:
        pass

    @abstractmethod
    def exists_by_codigo(self, codigo: str, session: Session) -> bool:
        pass

    @abstractmethod
    def get_active_coupons(self, session: Session, skip: int = 0, limit: int = 100) -> List[Coupon]:
        pass
