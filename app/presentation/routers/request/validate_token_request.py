from pydantic import BaseModel


class ValidateTokenRequest(BaseModel):
    token: str
    company_id: int
