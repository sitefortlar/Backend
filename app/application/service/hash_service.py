from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt
from loguru import logger

class HashService:
    def __init__(self):
        # Configuração do CryptContext com bcrypt
        # Versões fixas: passlib==1.7.4 e bcrypt==4.0.1 para evitar incompatibilidades
        try:
            self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
            # Testa se o backend está funcionando
            test_hash = self.pwd_context.hash("test")
            logger.info("✅ HashService inicializado com sucesso (bcrypt)")
        except Exception as e:
            logger.error(f"❌ Erro ao inicializar HashService: {e}")
            raise ValueError(f"Falha ao inicializar sistema de hash de senhas: {e}")

    def hash_password(self, password: str) -> str:
        """
        Gera hash da senha usando bcrypt.
        
        Args:
            password: Senha em texto plano
            
        Returns:
            Hash da senha
            
        Raises:
            ValueError: Se a senha for muito longa ou inválida
        """
        if not password:
            raise ValueError("Senha não pode ser vazia")
        
        # Validação de tamanho (bcrypt tem limite de 72 bytes)
        # Mas senhas normais não chegam perto disso
        if len(password.encode('utf-8')) > 72:
            raise ValueError("Senha muito longa (máximo 72 bytes)")
        
        try:
            return self.pwd_context.hash(password)
        except Exception as e:
            logger.error(f"Erro ao gerar hash da senha: {e}")
            raise ValueError(f"Erro ao processar senha: {e}")

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """
        Verifica se senha está correta.
        
        Args:
            plain_password: Senha em texto plano
            hashed_password: Hash armazenado
            
        Returns:
            True se a senha estiver correta, False caso contrário
        """
        if not plain_password or not hashed_password:
            return False
        
        try:
            return self.pwd_context.verify(plain_password, hashed_password)
        except Exception as e:
            logger.error(f"Erro ao verificar senha: {e}")
            return False

    def generate_email_token(self, empresa_id: int, expires_in_minutes: int = 60) -> str:
        """Gera token para verificação de e-mail"""
        payload = {
            "sub": str(empresa_id),
            "exp": datetime.utcnow() + timedelta(minutes=expires_in_minutes)
        }
        return jwt.encode(payload, "SECRET_EMAIL_KEY", algorithm="HS256")
