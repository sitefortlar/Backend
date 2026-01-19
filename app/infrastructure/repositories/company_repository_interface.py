from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.company_model import Company
from app.infrastructure.configs.database_config import Session
from pydantic import EmailStr


class ICompanyRepository(ABC):


    @abstractmethod
    def exists_by_cnpj(self, cnpj:str, session: Session):
        pass

    @abstractmethod
    def exists_by_email(self, email: EmailStr, session: Session):
        pass

    @abstractmethod
    def find_by_email_or_cnpj(self, login: str, session: Session) -> Optional[Company]:
        pass

    @abstractmethod
    def get_by_id(self, company_id: int, session: Session) -> Optional[Company]:
        pass

    @abstractmethod
    def get_by_id_and_role(self, company_id: int, role, session: Session) -> Optional[Company]:
        pass

    @abstractmethod
    def create_company_with_address_and_contact(self, company: Company, session: Session) -> int:
        pass

    @abstractmethod
    def update_company_ativo(self, company_id: int, session: Session) -> None:
        pass

    @abstractmethod
    def update_password(self, company_id: int, new_password: str, session: Session) -> None:
        pass

    @abstractmethod
    def update_company_ativo_status(self, company_id: int, ativo: bool, session: Session) -> None:
        pass

    @abstractmethod
    def get_by_cnpj(self, cnpj: str, session: Session) -> Optional[Company]:
        pass

    @abstractmethod
    def get_by_email(self, email: str, session: Session) -> Optional[Company]:
        pass

    @abstractmethod
    def get_active_companies(self, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        pass

    @abstractmethod
    def get_by_vendedor(self, vendedor_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        pass

    @abstractmethod
    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        pass

    @abstractmethod
    def update_status(self, company_id: int, ativo: bool, session: Session) -> bool:
        pass

    @abstractmethod
    def get_with_relations(self, company_id: int, session: Session) -> Optional[Company]:
        pass