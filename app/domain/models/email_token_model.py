from sqlalchemy import Integer, String, DateTime, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from typing import Optional
from datetime import datetime

from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin


class EmailToken(Base, BaseMixin):
    """Modelo de domínio para EmailToken"""
    __tablename__ = 'email_token'

    id_email: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_empresa: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('empresas.id_empresa', ondelete='CASCADE'), 
        nullable=False
    )
    tipo: Mapped[EmailTokenTypeEnum] = mapped_column(
        Enum(EmailTokenTypeEnum, name="email_token_type_enum"), 
        nullable=False
    )
    token: Mapped[str] = mapped_column(String(150), nullable=False, unique=True)
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now() + func.cast("1 hour", DateTime),
        nullable=False
    )

    # Relacionamentos
    empresa: Mapped[Optional['Company']] = relationship('Company', back_populates='email_token')

    def __init__(self, id_empresa, token, tipo):
        self.id_empresa = id_empresa
        self.token = token
        self.tipo = tipo