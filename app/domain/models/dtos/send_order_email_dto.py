"""DTOs para SendOrderEmailUseCase"""

from typing import List, Optional
from pydantic import BaseModel, Field
from enum import Enum


class FormaPagamentoEnum(str, Enum):
    """Enum para formas de pagamento"""
    AVISTA = "avista"
    DIAS_30 = "30_dias"
    DIAS_60 = "60_dias"


class OrderItemUseCaseRequest(BaseModel):
    """Item do order para o use case"""
    id_produto: int = Field(..., description="ID do produto")
    codigo: str = Field(..., description="Código do produto")
    nome: str = Field(..., description="Nome do produto")
    quantidade_pedida: int = Field(..., ge=1, description="Quantidade pedida do produto")
    valor_unitario: float = Field(..., ge=0, description="Valor unitário do produto")
    valor_total: float = Field(..., ge=0, description="Valor total do item")
    categoria: Optional[str] = Field(None, description="Categoria do produto")
    subcategoria: Optional[str] = Field(None, description="Subcategoria do produto")


class SendOrderEmailUseCaseRequest(BaseModel):
    """Request para o use case de envio de order por email"""
    company_id: int = Field(..., description="ID da empresa/cliente")
    itens: List[OrderItemUseCaseRequest] = Field(..., min_items=1, description="Lista de produtos do carrinho")
    forma_pagamento: FormaPagamentoEnum = Field(..., description="Forma de pagamento")


class SendOrderEmailUseCaseResponse(BaseModel):
    """Response do use case de envio de order por email"""
    message: str = Field(..., description="Mensagem de sucesso")
    email_enviado: str = Field(..., description="Email para onde foi enviado")
    valor_total: float = Field(..., description="Valor total do order")
    quantidade_itens: int = Field(..., description="Quantidade de itens no order")
    empresa: str = Field(..., description="Nome da empresa")
    forma_pagamento: str = Field(..., description="Forma de pagamento formatada")

