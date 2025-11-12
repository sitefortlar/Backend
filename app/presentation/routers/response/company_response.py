from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel

from app.infrastructure.configs.base_response import BaseResponseModel


class AddressResponse(BaseModel):
    """DTO para resposta de endereço"""
    id_endereco: int
    cep: str
    numero: str
    complemento: Optional[str] = None
    bairro: Optional[str] = None
    cidade: Optional[str] = None
    uf: str
    ibge: Optional[str] = None


class ContactResponse(BaseModel):
    """DTO para resposta de contato"""
    id_contato: int
    nome: str
    telefone: Optional[str] = None
    celular: Optional[str] = None
    email: str


class CompanyResponse(BaseResponseModel):
    """DTO para resposta de empresa"""
    id_empresa: int
    cnpj: str
    razao_social: str
    nome_fantasia: str
    perfil: str
    ativo: bool
    created_at: datetime
    updated_at: datetime
    enderecos: List[AddressResponse] = []
    contatos: List[ContactResponse] = []


