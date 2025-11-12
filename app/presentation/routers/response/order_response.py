"""DTOs para responses de orders"""

from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel


class OrderItemResponse(BaseModel):
    """Response para item do order"""
    id: int
    id_produto: int
    quantidade: int
    preco_unitario: float
    subtotal: float


class OrderResponse(BaseModel):
    """Response para order"""
    id: int
    id_cliente: int
    id_cupom: Optional[int]
    data_pedido: datetime
    status: str
    valor_total: float
    created_at: datetime
    updated_at: datetime
    itens: Optional[List[OrderItemResponse]] = None


class ListOrdersResponse(BaseModel):
    """Response para lista de orders"""
    orders: List[OrderResponse]
    total: int
    skip: int
    limit: int

