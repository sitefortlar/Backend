from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.email_token_model import EmailToken
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.configs.database_config import Session


class IEmailTokenRepository(ABC):
    """Interface para operações de EmailToken"""

    @abstractmethod
    def create(self, email_token: EmailToken, session: Session) -> EmailToken:
        """Cria um novo token de email"""
        pass

    @abstractmethod
    def get_by_id(self, token_id: int, session: Session) -> Optional[EmailToken]:
        """Busca token por ID"""
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[EmailToken]:
        """Lista todos os tokens"""
        pass

    @abstractmethod
    def update(self, email_token: EmailToken, session: Session) -> EmailToken:
        """Atualiza um token"""
        pass

    @abstractmethod
    def delete(self, token_id: int, session: Session) -> bool:
        """Deleta um token"""
        pass

    @abstractmethod
    def exists_by_token_and_company_id_and_type(self, token: str, company_id: int, type: EmailTokenTypeEnum,
                                                session: Session) -> bool:
        """Verifica se token existe por token, empresa e tipo"""
        pass

    @abstractmethod
    def get_by_company_id(self, company_id: int, session: Session) -> Optional[EmailToken]:
        """Busca token por empresa"""
        pass

    @abstractmethod
    def create_email_token(self, email_token: EmailToken, session: Session) -> int:
        """Cria token de email (método legado)"""
        pass

    @abstractmethod
    def delete_by_token_and_company_id(self, token: str, company_id: int, session: Session) -> None:
        """Deleta token por token e empresa"""
        pass

    @abstractmethod
    def get_by_token(self, token: str, session: Session) -> Optional[EmailToken]:
        """Busca token por valor do token"""
        pass

    @abstractmethod
    def get_by_type(self, token_type: EmailTokenTypeEnum, session: Session) -> List[EmailToken]:
        """Busca tokens por tipo"""
        pass

    @abstractmethod
    def get_expired_tokens(self, session: Session) -> List[EmailToken]:
        """Busca tokens expirados"""
        pass

    @abstractmethod
    def delete_by_company_id_and_type(self, company_id: int, token_type: EmailTokenTypeEnum, session: Session) -> None:
        """Deleta tokens por empresa e tipo"""
        pass
