from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt

class HashService:
    def __init__(self):
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    def hash_password(self, password: str) -> str:
        """Gera hash da senha"""
        return self.pwd_context.hash(password)

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verifica se senha está correta"""
        return self.pwd_context.verify(plain_password, hashed_password)

    def generate_email_token(self, empresa_id: int, expires_in_minutes: int = 60) -> str:
        """Gera token para verificação de e-mail"""
        payload = {
            "sub": str(empresa_id),
            "exp": datetime.utcnow() + timedelta(minutes=expires_in_minutes)
        }
        return jwt.encode(payload, "SECRET_EMAIL_KEY", algorithm="HS256")
