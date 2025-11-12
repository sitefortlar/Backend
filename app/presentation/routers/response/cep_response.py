"""DTOs para responses de CEP"""

from typing import Optional
from pydantic import BaseModel


class CepResponse(BaseModel):
    """Response para consulta de CEP"""
    cep: str
    logradouro: str
    complemento: Optional[str] = None
    bairro: str
    cidade: str
    uf: str

    class Config:
        json_schema_extra = {
            "example": {
                "cep": "01310-100",
                "logradouro": "Avenida Paulista",
                "complemento": None,
                "bairro": "Bela Vista",
                "cidade": "São Paulo",
                "uf": "SP"
            }
        }
