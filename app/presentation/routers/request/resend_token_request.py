from pydantic import BaseModel, EmailStr

class ResendTokenRequest(BaseModel):
    company_id: int | None = None
    email: EmailStr | None = None

