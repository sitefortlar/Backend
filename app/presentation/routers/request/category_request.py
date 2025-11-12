"""Request models for category operations"""

from typing import List
from pydantic import BaseModel, Field


class SubcategoryRequest(BaseModel):
    """Request model for subcategory"""
    name: str = Field(..., description="Subcategory name", min_length=1)


class CategoryRequest(BaseModel):
    """Request model for category with subcategories"""
    name: str = Field(..., description="Category name", min_length=1)
    subcategory: List[SubcategoryRequest] = Field(
        default=[], 
        description="List of subcategories (optional)"
    )


