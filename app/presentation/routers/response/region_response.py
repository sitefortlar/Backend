"""Response models for region operations"""

from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel


class RegionResponse(BaseModel):
    """Response model for region"""
    id: int
    estado: str
    desconto_0: Decimal
    desconto_30: Decimal
    desconto_60: Decimal
    created_at: datetime
    updated_at: datetime

