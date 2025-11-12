from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import List

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin


class ActivityBranch(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Ramo de Atividade"""
    __tablename__ = 'ramo_atividade'

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    descricao: Mapped[str] = mapped_column(String(150), nullable=False)

    # Relacionamentos
    empresas: Mapped[List['Company']] = relationship('Company', back_populates='ramo')

    def __init__(self, descricao):
        self.descricao = descricao