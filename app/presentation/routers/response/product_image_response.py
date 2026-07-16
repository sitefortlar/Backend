"""DTOs para responses de imagens de produto"""

from typing import List
from pydantic import BaseModel


class ProductImageResponse(BaseModel):
    """Response para uma imagem de produto adicionada"""
    id_imagem: int
    url: str
    id_produto: int


class DeleteProductImagesResponse(BaseModel):
    """Response para exclusão em lote de imagens de produto"""
    removidas: List[int]
    nao_encontradas: List[int]
