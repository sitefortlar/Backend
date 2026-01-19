from typing import Optional, List

from app.domain.models.seller_model import Seller
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.seller_repository_interface import ISellerRepository


class SellerRepositoryImpl(ISellerRepository):
    """Repository para operações de Seller com CRUD completo"""

    def create(self, seller: Seller, session: Session) -> Seller:
        """Cria um novo vendedor"""
        session.add(seller)
        session.flush()
        return seller

    def get_by_id(self, seller_id: int, session: Session) -> Optional[Seller]:
        """Busca vendedor por ID"""
        return session.query(Seller).filter(Seller.id_vendedor == seller_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Lista todos os vendedores"""
        return session.query(Seller).offset(skip).limit(limit).all()

    def update(self, seller: Seller, session: Session) -> Seller:
        """Atualiza um vendedor"""
        session.merge(seller)
        session.flush()
        return seller

    def delete(self, seller_id: int, session: Session) -> bool:
        """Deleta um vendedor"""
        seller = self.get_by_id(seller_id, session)
        if seller:
            session.delete(seller)
            session.flush()
            return True
        return False

    def exists_by_id(self, seller_id: int, session: Session) -> bool:
        """Verifica se vendedor existe por ID"""
        from sqlalchemy import exists
        return session.query(exists().where(Seller.id_vendedor == seller_id)).scalar()

    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Busca vendedores por nome"""
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Seller).filter(
            Seller.nome.ilike(f"%{name.strip()}%")
        ).offset(skip).limit(limit).all()

    def get_active_sellers(self, session: Session, skip: int = 0, limit: int = 100) -> List[Seller]:
        """Busca vendedores ativos"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Seller).filter(Seller.ativo == True).offset(skip).limit(limit).all()
