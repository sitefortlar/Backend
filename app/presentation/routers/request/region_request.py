"""Request models for region operations"""

from decimal import Decimal
from pydantic import BaseModel, Field


class RegionRequest(BaseModel):
    """Request model for region"""
    estado: str = Field(..., description="Estado da região", min_length=1, max_length=100)
    desconto_0: Decimal = Field(..., description="Desconto para prazo 0 dias", ge=0)
    desconto_30: Decimal = Field(..., description="Desconto para prazo 30 dias", ge=0)
    desconto_60: Decimal = Field(..., description="Desconto para prazo 60 dias", ge=0)

