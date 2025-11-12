from sqlalchemy import Integer, Text, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin


class ProductImage(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Imagem do Product"""
    __tablename__ = 'imagens_produto'

    id_imagem: Mapped[int] = mapped_column(Integer, primary_key=True)
    id_produto: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('produtos.id_produto', ondelete='CASCADE'), 
        nullable=False
    )
    url: Mapped[str] = mapped_column(Text, nullable=False)

    # Relacionamento
    produto: Mapped[Optional['Product']] = relationship('Product', back_populates='imagens')

    def __init__(self, id_produto, url):
        self.id_produto = id_produto
        self.url = url