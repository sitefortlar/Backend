"""Request models para operações de produto"""

from typing import Optional
from pydantic import BaseModel, Field


class UpdateProductRequest(BaseModel):
    """Request para atualização parcial de produto (todos os campos opcionais)"""
    nome: Optional[str] = Field(None, description="Nome do produto", min_length=1, max_length=150)
    descricao: Optional[str] = Field(None, description="Descrição do produto")
    quantidade: Optional[int] = Field(None, ge=1, description="Quantidade")
    cod_kit: Optional[str] = Field(None, max_length=50, description="Código do kit (amarração)")
    id_categoria: Optional[int] = Field(None, description="ID da categoria")
    id_subcategoria: Optional[int] = Field(None, description="ID da subcategoria")
    valor_base: Optional[float] = Field(None, ge=0, description="Valor base do produto")
    ativo: Optional[bool] = Field(None, description="Produto ativo/inativo")
