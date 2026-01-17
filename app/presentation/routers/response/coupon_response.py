"""Response models for coupon operations"""

from typing import Optional
from datetime import datetime, date
from decimal import Decimal
from pydantic import BaseModel

from app.domain.models.coupon_model import CouponTypeEnum


class CouponResponse(BaseModel):
    """Response model for coupon"""
    id_cupom: int
    codigo: str
    tipo: CouponTypeEnum
    valor: Decimal
    validade_inicio: Optional[date]
    validade_fim: Optional[date]
    ativo: bool
    created_at: datetime
    updated_at: datetime


class ValidateCouponResponse(BaseModel):
    """Response model for coupon validation"""
    valid: bool
    coupon: Optional[CouponResponse] = None
    message: str
