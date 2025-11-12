from typing import Annotated
from pydantic import BaseModel, constr

from app.presentation.routers.request.company_address_request import CompanyAddressRequest
from app.presentation.routers.request.company_contact_request import CompanyContactRequest

SenhaType = Annotated[str, constr(min_length=6)]


class CompanyRequest(BaseModel):
    cnpj: Annotated[str, constr(min_length=14, max_length=20)]
    razao_social: str
    nome_fantasia: str
    senha: SenhaType
    endereco: CompanyAddressRequest
    contato: CompanyContactRequest
