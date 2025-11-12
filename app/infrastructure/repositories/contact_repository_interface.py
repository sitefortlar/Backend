"""Interface do repository para Contact"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.contact_model import Contact
from app.infrastructure.configs.database_config import Session


class IContactRepository(ABC):
    """Interface para operações de Contact"""

    @abstractmethod
    def create(self, contact: Contact, session: Session) -> Contact:
        pass

    @abstractmethod
    def get_by_id(self, contact_id: int, session: Session) -> Optional[Contact]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
        pass

    @abstractmethod
    def update(self, contact: Contact, session: Session) -> Contact:
        pass

    @abstractmethod
    def delete(self, contact_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_email(self, email: str, session: Session) -> Optional[Contact]:
        pass

    @abstractmethod
    def get_by_company(self, company_id: int, session: Session) -> List[Contact]:
        pass

    @abstractmethod
    def exists_by_email(self, email: str, session: Session) -> bool:
        pass
