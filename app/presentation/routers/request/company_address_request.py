from typing import Annotated
from pydantic import BaseModel, constr

CepType = Annotated[str, constr(min_length=8, max_length=20)]
UfType = Annotated[str, constr(min_length=2, max_length=2)]


class CompanyAddressRequest(BaseModel):
    cep: CepType
    numero: str
    complemento: str | None = None
    bairro: str
    cidade: str
    uf: UfType
    ibge: str