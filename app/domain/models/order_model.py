from sqlalchemy import Integer, Numeric, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional, List
from decimal import Decimal
from datetime import datetime

from app.domain.models.enumerations.order_status_enumerations import OrderStatusEnum
from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos
from app.domain.models.order_item_model import OrderItem
from app.domain.models.coupon_model import Coupon
from typing import TYPE_CHECKING


if TYPE_CHECKING:
    from app.domain.models.company_model import Company




class Order(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Order"""
    __tablename__ = 'pedidos'

    id_pedido: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_cliente: Mapped[int] = mapped_column(Integer, ForeignKey('empresas.id_empresa'), nullable=False)
    id_cupom: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey('cupons.id_cupom'), nullable=True)
    # data_pedido removido - usar created_at do TimestampMixin
    status: Mapped[OrderStatusEnum] = mapped_column(
        Enum(OrderStatusEnum, name='pedido_status'), 
        nullable=False, 
        default=OrderStatusEnum.PENDENTE
    )
    valor_total: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    
    @property
    def data_pedido(self) -> datetime:
        """Retorna created_at como data_pedido para compatibilidade"""
        return self.created_at

    # Relacionamentos
    cliente: Mapped[Optional['Company']] = relationship('Company')
    cupom: Mapped[Optional['Coupon']] = relationship('Coupon', back_populates='pedidos')
    itens: Mapped[List['OrderItem']] = relationship(
        'OrderItem',
        back_populates='order',
        cascade='all,delete-orphan'
    )

    def __init__(self, id_cliente, valor_total, id_cupom=None, status=OrderStatusEnum.PENDENTE):
        self.id_cliente = id_cliente
        self.id_cupom = id_cupom
        self.status = status
        self.valor_total = valor_total