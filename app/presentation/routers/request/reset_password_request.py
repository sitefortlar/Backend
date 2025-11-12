from pydantic import BaseModel

class ResetPasswordRequest(BaseModel):
    token: str
    company_id: int
    new_password: str
    confirm_password: str
