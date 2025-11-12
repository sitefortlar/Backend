from pydantic import BaseModel
from datetime import datetime


class AddressResponse(BaseModel):
    id_endereco: int
    cep: str
    numero: str
    complemento: str | None = None
    bairro: str | None = None
    cidade: str | None = None
    uf: str
    ibge: str | None = None
    created_at: datetime
    updated_at: datetime

