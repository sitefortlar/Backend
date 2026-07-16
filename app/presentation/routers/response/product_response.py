"""DTOs para responses de produtos"""

from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, Field


class ImagemDetalhe(BaseModel):
    """Imagem do produto com o id necessário para exclusão (DELETE /product/{id}/images)"""
    id_imagem: int
    url: str


class ProductResponse(BaseModel):
    """Response para produto"""
    id_produto: int
    codigo: str
    nome: str
    descricao: Optional[str] = None
    quantidade: int = 1
    cod_kit: Optional[str] = None
    id_categoria: int
    id_subcategoria: Optional[int] = None
    valor_base: float
    ativo: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    categoria: Optional[str] = None
    subcategoria: Optional[str] = None
    imagens: List[str] = []
    imagens_detalhe: List[ImagemDetalhe] = []
    avista: Optional[float] = None
    dias_30: Optional[float] = Field(None, alias="30_dias")
    dias_60: Optional[float] = Field(None, alias="60_dias")
    valor_base_total: Optional[float] = None
    valor_total_avista: Optional[float] = None
    valor_total_30: Optional[float] = None
    valor_total_60: Optional[float] = None
    kits: List['ProductResponse'] = []
    
    class Config:
        populate_by_name = True
        # Permite modelos recursivos


