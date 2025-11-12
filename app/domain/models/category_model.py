from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import List

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos
from app.domain.models.subcategory_model import Subcategory
from app.domain.models.product_model import Product



class Category(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Category"""
    __tablename__ = 'categoria'

    id_categoria: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    nome: Mapped[str] = mapped_column(String(150), nullable=False, unique=True)

    # Relacionamentos
    subcategorias: Mapped[List['Subcategory']] = relationship(
        'Subcategory', 
        back_populates='categoria', 
        cascade='all,delete-orphan'
    )
    produtos: Mapped[List['Product']] = relationship('Product', back_populates='categoria')

    def __init__(self, nome):
        self.nome = nome