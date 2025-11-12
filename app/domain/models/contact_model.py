from sqlalchemy import Integer, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin


class Contact(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Contato"""
    __tablename__ = 'contatos'

    id_contato: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_empresa: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('empresas.id_empresa', ondelete='CASCADE'), 
        nullable=False
    )
    nome: Mapped[str] = mapped_column(String(150), nullable=False)
    telefone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    celular: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    email: Mapped[str] = mapped_column(String(150), nullable=False)

    # Relacionamento
    empresa: Mapped[Optional['Company']] = relationship('Company', back_populates='contatos')

    def __init__(self, nome, email, telefone=None, celular=None, id_empresa=None):
        self.nome = nome
        self.email = email
        self.telefone = telefone
        self.celular = celular
        self.id_empresa = id_empresa