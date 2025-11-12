from sqlalchemy import Integer, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import List

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos (Subcategory é "filho" de Category, usa string)



class Subcategory(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Subcategory"""
    __tablename__ = 'subcategoria'

    id_subcategoria: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_categoria: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('categoria.id_categoria', ondelete='CASCADE'), 
        nullable=False
    )
    nome: Mapped[str] = mapped_column(String(150), nullable=False)

    # Relacionamentos
    categoria: Mapped['Category'] = relationship('Category', back_populates='subcategorias')
    produtos: Mapped[List['Product']] = relationship('Product', back_populates='subcategoria')

    def __init__(self, nome, id_categoria):
        self.nome = nome
        self.id_categoria = id_categoria




