"""DTOs para requests de orders"""

from typing import Optional, List
from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field


class FormaPagamentoEnum(str, Enum):
    """Enum para formas de pagamento"""
    AVISTA = "avista"
    DIAS_30 = "30_dias"
    DIAS_60 = "60_dias"


class ListOrdersRequest(BaseModel):
    """Request para listar orders"""
    skip: int = Field(0, ge=0, description="Número de registros para pular")
    limit: int = Field(100, ge=1, le=1000, description="Número máximo de registros")
    cliente_id: Optional[int] = Field(None, description="Filtrar por cliente")
    status: Optional[str] = Field(None, description="Filtrar por status")
    cupom_id: Optional[int] = Field(None, description="Filtrar por cupom")
    start_date: Optional[datetime] = Field(None, description="Data inicial")
    end_date: Optional[datetime] = Field(None, description="Data final")
    min_value: Optional[float] = Field(None, ge=0, description="Valor mínimo")
    max_value: Optional[float] = Field(None, ge=0, description="Valor máximo")


class GetOrderRequest(BaseModel):
    """Request para buscar order por ID"""
    order_id: int = Field(..., description="ID do order")
    include_items: bool = Field(False, description="Incluir itens do order")


class ListOrdersByClienteRequest(BaseModel):
    """Request para listar orders por cliente"""
    cliente_id: int = Field(..., description="ID do cliente")


class ListOrdersByStatusRequest(BaseModel):
    """Request para listar orders por status"""
    status: str = Field(..., description="Status do order")


class ListOrdersRecentesRequest(BaseModel):
    """Request para listar orders recentes"""
    days: int = Field(7, ge=1, le=365, description="Número de dias")


class ItemCarrinhoRequest(BaseModel):
    """Item do carrinho"""
    id_produto: int = Field(..., description="ID do produto")
    quantidade: int = Field(..., ge=1, description="Quantidade do produto")
    preco_unitario: float = Field(..., ge=0, description="Preço unitário do produto")


class EnvioOrderRequest(BaseModel):
    """Request para envio de order"""
    id_cliente: int = Field(..., description="ID do cliente (empresa)")
    itens: List[ItemCarrinhoRequest] = Field(..., min_items=1, description="Lista de itens do carrinho")
    forma_pagamento: str = Field(..., description="Forma de pagamento")


class OrderItemRequest(BaseModel):
    """Item do order com valores já calculados"""
    id_produto: int = Field(..., description="ID do produto")
    codigo: str = Field(..., description="Código do produto")
    nome: str = Field(..., description="Nome do produto")
    quantidade_pedida: int = Field(..., ge=1, description="Quantidade pedida do produto")
    valor_unitario: float = Field(..., ge=0, description="Valor unitário do produto (já calculado baseado na forma de pagamento)")
    valor_total: float = Field(..., ge=0, description="Valor total do item (quantidade * valor_unitario)")
    categoria: Optional[str] = Field(None, description="Categoria do produto")
    subcategoria: Optional[str] = Field(None, description="Subcategoria do produto")


class SendOrderEmailRequest(BaseModel):
    """Request para envio de order por email com itens simplificados"""
    company_id: int = Field(..., description="ID da empresa/cliente")
    itens: List[OrderItemRequest] = Field(..., min_items=1, description="Lista de produtos do carrinho com valores calculados")
    forma_pagamento: FormaPagamentoEnum = Field(..., description="Forma de pagamento: avista, 30_dias ou 60_dias")

