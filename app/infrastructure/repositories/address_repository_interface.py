"""Interface do repository para Address"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.address_model import Address
from app.infrastructure.configs.database_config import Session


class IAddressRepository(ABC):
    """Interface para operações de Address"""

    @abstractmethod
    def create(self, address: Address, session: Session) -> Address:
        pass

    @abstractmethod
    def get_by_id(self, address_id: int, session: Session) -> Optional[Address]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Address]:
        pass

    @abstractmethod
    def update(self, address: Address, session: Session) -> Address:
        pass

    @abstractmethod
    def delete(self, address_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_company(self, company_id: int, session: Session) -> List[Address]:
        pass

    @abstractmethod
    def get_by_cep(self, cep: str, session: Session) -> List[Address]:
        pass

    @abstractmethod
    def get_by_city(self, city: str, session: Session) -> List[Address]:
        pass

    @abstractmethod
    def get_by_state(self, state: str, session: Session) -> List[Address]:
        pass
