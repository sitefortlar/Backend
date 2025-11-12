from typing import Optional, List
from datetime import datetime

from app.domain.models.email_token_model import EmailToken
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.email_token_repository_interface import IEmailTokenRepository

from sqlalchemy import and_


class EmailTokenRepositoryImpl(IEmailTokenRepository):
    """Repository para operações de EmailToken com CRUD completo"""

    def create(self, email_token: EmailToken, session: Session) -> EmailToken:
        """Cria um novo token de email"""
        session.add(email_token)
        session.flush()
        return email_token

    def get_by_id(self, token_id: int, session: Session) -> Optional[EmailToken]:
        """Busca token por ID"""
        return session.query(EmailToken).filter(EmailToken.id == token_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[EmailToken]:
        """Lista todos os tokens"""
        return session.query(EmailToken).offset(skip).limit(limit).all()

    def update(self, email_token: EmailToken, session: Session) -> EmailToken:
        """Atualiza um token"""
        session.merge(email_token)
        session.flush()
        return email_token

    def delete(self, token_id: int, session: Session) -> bool:
        """Deleta um token"""
        token = self.get_by_id(token_id, session)
        if token:
            session.delete(token)
            session.flush()
            return True
        return False

    def exists_by_token_and_company_id_and_type(self, token: str, company_id: int, type: EmailTokenTypeEnum,
                                                session: Session) -> bool:
        """Verifica se token existe por token, empresa e tipo"""
        return session.query(EmailToken).filter(and_(EmailToken.token == token,
                                                     EmailToken.id_empresa == company_id,
                                                     EmailToken.tipo == type)
                                                ).first() is not None

    def get_by_company_id(self, company_id: int, session: Session) -> Optional[EmailToken]:
        """Busca token por empresa"""
        return session.query(EmailToken).filter(EmailToken.id_empresa == company_id).first()

    def create_email_token(self, email_token: EmailToken, session: Session) -> int:
        """Cria token de email (método legado)"""
        session.add(email_token)
        session.flush()
        return email_token.id_empresa

    def delete_by_token_and_company_id(self, token: str, company_id: int, session: Session) -> None:
        """Deleta token por token e empresa"""
        session.query(EmailToken).filter(
            and_(EmailToken.token == token, EmailToken.id_empresa == company_id)
        ).delete()
        session.flush()

    def get_by_token(self, token: str, session: Session) -> Optional[EmailToken]:
        """Busca token por valor do token"""
        return session.query(EmailToken).filter(EmailToken.token == token).first()

    def get_by_type(self, token_type: EmailTokenTypeEnum, session: Session) -> List[EmailToken]:
        """Busca tokens por tipo"""
        return session.query(EmailToken).filter(EmailToken.tipo == token_type).all()

    def get_expired_tokens(self, session: Session) -> List[EmailToken]:
        """Busca tokens expirados (assumindo que há um campo de expiração)"""
        # Assumindo que há um campo created_at e tokens expiram em 24h
        from datetime import timedelta
        expiration_time = datetime.utcnow() - timedelta(hours=24)
        return session.query(EmailToken).filter(EmailToken.created_at < expiration_time).all()

    def delete_by_company_id_and_type(self, company_id: int, token_type: EmailTokenTypeEnum, session: Session) -> None:
        """Deleta tokens por empresa e tipo"""
        session.query(EmailToken).filter(
            and_(EmailToken.id_empresa == company_id, EmailToken.tipo == token_type)
        ).delete()
        session.flush()