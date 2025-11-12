from pydantic import BaseModel, EmailStr
from typing import Union

class LoginRequest(BaseModel):
    login: Union[EmailStr, str]
    password: str
