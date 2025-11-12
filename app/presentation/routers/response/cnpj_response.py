"""DTOs para responses de CNPJ"""

from typing import Optional
from pydantic import BaseModel


class CnpjResponse(BaseModel):
    """Response para consulta de CNPJ"""
    cnpj: str
    razao_social: str
    fantasia: Optional[str] = None
    cep: str
    logradouro: str
    numero: str
    complemento: Optional[str] = None
    bairro: str
    municipio: str
    uf: str
    telefone: Optional[str] = None
    email: Optional[str] = None
    atividade_principal: Optional[str] = None

    class Config:
        json_schema_extra = {
            "example": {
                "cnpj": "05495693000154",
                "razao_social": "Empresa Exemplo Ltda",
                "fantasia": "Exemplo Corp",
                "cep": "01310-100",
                "logradouro": "Avenida Paulista",
                "numero": "1000",
                "complemento": "Sala 100",
                "bairro": "Bela Vista",
                "municipio": "São Paulo",
                "uf": "SP",
                "telefone": "(11) 99999-9999",
                "email": "contato@exemplo.com",
                "atividade_principal": "Desenvolvimento de software"
            }
        }

