from pydantic import BaseModel, EmailStr
from datetime import datetime


class ContactResponse(BaseModel):
    id_contato: int
    nome: str
    telefone: str
    celular: str
    email: EmailStr
    created_at: datetime
    updated_at: datetime

