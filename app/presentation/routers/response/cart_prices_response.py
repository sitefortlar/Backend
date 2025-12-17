"""DTOs para response de preços do carrinho"""

from typing import List, Optional
from pydantic import BaseModel


class CartPriceItemResponse(BaseModel):
    id_produto: int
    found: bool
    codigo: Optional[str] = None
    nome: Optional[str] = None
    ativo: Optional[bool] = None
    valor_base: Optional[float] = None
    preco: Optional[float] = None
    error: Optional[str] = None


class CartPricesResponse(BaseModel):
    estado_request: str
    estado_calculo: str
    prazo: int
    multiplier: float
    items: List[CartPriceItemResponse]


