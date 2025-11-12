from sqlalchemy import Integer, Numeric, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional
from decimal import Decimal

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

from app.domain.models.product_model import Product


class OrderItem(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Item do Order"""
    __tablename__ = 'itens_pedido'

    id_item: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_pedido: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('pedidos.id_pedido', ondelete='CASCADE'), 
        nullable=False
    )
    id_produto: Mapped[int] = mapped_column(Integer, ForeignKey('produtos.id_produto'), nullable=False)
    quantidade: Mapped[int] = mapped_column(Integer, nullable=False)
    preco_unitario: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    subtotal: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)

    # Relacionamentos
    order: Mapped[Optional['Order']] = relationship('Order', back_populates='itens')
    produto: Mapped[Optional['Product']] = relationship('Product', back_populates='itens_pedido')

    def __init__(self, id_pedido, id_produto, quantidade, preco_unitario, subtotal):
        self.id_pedido = id_pedido
        self.id_produto = id_produto
        self.quantidade = quantidade
        self.preco_unitario = preco_unitario
        self.subtotal = subtotal