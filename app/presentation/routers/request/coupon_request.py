"""Request models for coupon operations"""

from typing import Optional
from decimal import Decimal
from datetime import date
from pydantic import BaseModel, Field

from app.domain.models.coupon_model import CouponTypeEnum


class CouponRequest(BaseModel):
    """Request model for creating coupon"""
    codigo: str = Field(..., description="Código do cupom", min_length=1, max_length=50)
    tipo: CouponTypeEnum = Field(..., description="Tipo do cupom: percentual ou valor_fixo")
    valor: Decimal = Field(..., description="Valor do desconto", gt=0)
    validade_inicio: Optional[date] = Field(None, description="Data de início da validade")
    validade_fim: Optional[date] = Field(None, description="Data de fim da validade")
    ativo: bool = Field(True, description="Se o cupom está ativo")


class UpdateCouponRequest(BaseModel):
    """Request model for updating coupon"""
    codigo: Optional[str] = Field(None, description="Código do cupom", min_length=1, max_length=50)
    tipo: Optional[CouponTypeEnum] = Field(None, description="Tipo do cupom: percentual ou valor_fixo")
    valor: Optional[Decimal] = Field(None, description="Valor do desconto", gt=0)
    validade_inicio: Optional[date] = Field(None, description="Data de início da validade")
    validade_fim: Optional[date] = Field(None, description="Data de fim da validade")
    ativo: Optional[bool] = Field(None, description="Se o cupom está ativo")
