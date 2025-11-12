from sqlalchemy import Integer, String, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import List
from decimal import Decimal

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos
from app.domain.models.product_price_model import ProductPrice


class Regions(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Regiões"""
    __tablename__ = 'regioes'

    id_regiao: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    estado: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)
    desconto_0: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    desconto_30: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    desconto_60: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)

    # Relacionamentos
    precos: Mapped[List['ProductPrice']] = relationship('ProductPrice', back_populates='regiao')

    def __init__(self, estado, desconto_0, desconto_30, desconto_60):
        self.estado = estado
        self.desconto_0 = desconto_0
        self.desconto_30 = desconto_30
        self.desconto_60 = desconto_60