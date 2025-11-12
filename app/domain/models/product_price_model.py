from sqlalchemy import Integer, ForeignKey, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional
from decimal import Decimal

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos (PrecoProduto é "filho", usa strings nas relationships)


class ProductPrice(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Preço do Product por Região e Prazo"""
    __tablename__ = 'precos_produto'

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_produto: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('produtos.id_produto', ondelete='CASCADE'), 
        nullable=False
    )
    id_regiao: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('regioes.id_regiao', ondelete='RESTRICT'),
        nullable=False
    )

    preco_0: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    preco_30: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    preco_60: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)

    # Relacionamentos
    produto: Mapped[Optional['Product']] = relationship('Product')
    regiao: Mapped[Optional['Regions']] = relationship('Regions', back_populates='precos')

    def __init__(self, id_produto, id_regiao, preco_0, preco_30, preco_60):
        self.id_produto = id_produto
        self.id_regiao = id_regiao
        self.preco_0 = preco_0
        self.preco_30 = preco_30
        self.preco_60 = preco_60

    # opcional: UniqueConstraint(produto_id, regiao_id, prazo_id)