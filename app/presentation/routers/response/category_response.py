"""Response models for category operations"""

from datetime import datetime
from typing import List
from pydantic import BaseModel


class SubcategoryResponse(BaseModel):
    """Response model for subcategory"""
    id_subcategoria: int
    nome: str
    id_categoria: int
    created_at: datetime
    updated_at: datetime


class CategoryResponse(BaseModel):
    """Response model for category"""
    id_categoria: int
    nome: str
    created_at: datetime
    updated_at: datetime
    subcategorias: List[SubcategoryResponse] = []


