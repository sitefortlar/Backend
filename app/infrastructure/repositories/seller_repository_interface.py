from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.seller_model import Seller
from app.infrastructure.configs.database_config import Session


class ISellerRepository(ABC):
    """Interface para operações de Seller (Vendedor)"""

    @abstractmethod
    def create(self, seller: Seller, session: Session) -> Seller:
        """Cria um novo vendedor"""
        pass

    @abstractmethod
    def get_by_id(self, seller_id: int, session: Session) -> Optional[Seller]:
        """Busca vendedor por ID"""
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Lista todos os vendedores"""
        pass

    @abstractmethod
    def update(self, seller: Seller, session: Session) -> Seller:
        """Atualiza um vendedor"""
        pass

    @abstractmethod
    def delete(self, seller_id: int, session: Session) -> bool:
        """Deleta um vendedor"""
        pass

    @abstractmethod
    def exists_by_id(self, seller_id: int, session: Session) -> bool:
        """Verifica se vendedor existe por ID"""
        pass

    @abstractmethod
    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Busca vendedores por nome"""
        pass

    @abstractmethod
    def get_active_sellers(self, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Busca vendedores ativos"""
        pass
