import jwt
from datetime import datetime, timedelta
from typing import Dict, Optional
import os

class JWTService:
    def __init__(self, secret_key: Optional[str] = None, algorithm: str = "HS256", expires_minutes: int = 60*24):
        self.secret_key = secret_key or os.getenv("JWT_SECRET_KEY", "sua_chave_secreta_aqui")
        self.algorithm = algorithm
        self.expires_minutes = expires_minutes

    def generate_token(self, data: Dict, expires_minutes: Optional[int] = None) -> str:
        """
        Gera token JWT
        
        Args:
            data: Dados para incluir no payload
            expires_minutes: Tempo de expiração em minutos (opcional, usa o padrão se não informado)
        """
        payload = data.copy()
        exp_minutes = expires_minutes or self.expires_minutes
        payload.update({
            "iat": datetime.utcnow(),
            "exp": datetime.utcnow() + timedelta(minutes=exp_minutes)
        })
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)

    def decode_token(self, token: str) -> Dict:
        """Decodifica token JWT"""
        try:
            return jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
        except jwt.ExpiredSignatureError:
            raise ValueError("Token expirado")
        except jwt.InvalidTokenError:
            raise ValueError("Token inválido")

    def is_token_valid(self, token: str) -> bool:
        """Verifica se o token é válido"""
        try:
            self.decode_token(token)
            return True
        except ValueError:
            return False

    def get_token_expiration(self, token: str) -> Optional[datetime]:
        """Retorna a data de expiração do token"""
        try:
            payload = self.decode_token(token)
            return datetime.fromtimestamp(payload.get("exp", 0))
        except ValueError:
            return None
