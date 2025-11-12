"""DTOs para responses de produtos"""

from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

from app.presentation.routers.response.product_response import ProductResponse


class ListProductsResponse(BaseModel):
    """Response para lista de produtos"""
    products: List[ProductResponse]
    total: int
    skip: int
    limit: int
