from sqlalchemy import Integer, String, Boolean, Date, Numeric, CheckConstraint, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional, List
from decimal import Decimal
from datetime import date
from enum import Enum as PyEnum

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin



class CouponTypeEnum(PyEnum):
    """Enum para tipo de cupom"""
    PERCENTUAL = 'percentual'
    VALOR_FIXO = 'valor_fixo'


class Coupon(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Cupom"""
    __tablename__ = 'cupons'

    id_cupom: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    codigo: Mapped[str] = mapped_column(String(50), nullable=False, unique=True, index=True)
    tipo: Mapped[CouponTypeEnum] = mapped_column(
        Enum(CouponTypeEnum, name='tipo_cupom'), 
        nullable=False
    )
    valor: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    validade_inicio: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    validade_fim: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    ativo: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    __table_args__ = (
        CheckConstraint("tipo IN ('percentual','valor_fixo')", name='chk_cupons_tipo'),
    )

    # Relacionamentos
    pedidos: Mapped[List['Order']] = relationship('Order', back_populates='cupom')

    def __init__(self, codigo, tipo, valor, validade_inicio=None, validade_fim=None, ativo=True):
        self.codigo = codigo
        self.tipo = tipo
        self.valor = valor
        self.validade_inicio = validade_inicio
        self.validade_fim = validade_fim
        self.ativo = ativo