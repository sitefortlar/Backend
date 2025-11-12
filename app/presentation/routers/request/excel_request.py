"""DTOs para requests de upload de Excel"""

from typing import Optional
from pydantic import BaseModel, Field


class ExcelUploadRequest(BaseModel):
    """Request para upload de planilha Excel"""
    file_path: str = Field(..., description="Caminho para o arquivo Excel")
    validate_only: bool = Field(False, description="Apenas validar estrutura do arquivo")


class ExcelValidationResponse(BaseModel):
    """Response para validação de arquivo Excel"""
    valid: bool
    total_rows: Optional[int] = None
    columns: Optional[list] = None
    message: str
    error: Optional[str] = None


class BulkCreateResponse(BaseModel):
    """Response para criação em lote"""
    success: bool
    total_processed: int
    created_count: int
    error_count: int
    created_products: list
    errors: list
    message: str
