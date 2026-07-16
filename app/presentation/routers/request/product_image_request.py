"""Request models para operações de imagem de produto"""

from typing import List
from pydantic import BaseModel, Field


class DeleteProductImagesRequest(BaseModel):
    """Request para exclusão em lote de imagens de produto"""
    image_ids: List[int] = Field(..., min_length=1, description="IDs das imagens a remover")
