from pydantic import BaseModel, EmailStr


class CompanyContactRequest(BaseModel):
    nome: str
    telefone: str
    celular: str
    email: EmailStr
