"""Implementação do repository para Subcategory"""

from typing import Optional, List

from app.domain.models.subcategory_model import Subcategory
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository


class SubcategoryRepositoryImpl(ISubcategoryRepository):
    """Repository para operações de Subcategory com CRUD completo"""

    # Implementação dos métodos abstratos do ISubcategoryRepository
    def create(self, subcategory: Subcategory, session: Session) -> Subcategory:
        """Cria uma nova subcategory"""
        session.add(subcategory)
        session.flush()
        return subcategory

    def get_by_id(self, subcategory_id: int, session: Session) -> Optional[Subcategory]:
        """Busca subcategory por ID"""
        return session.query(Subcategory).filter(Subcategory.id_subcategoria == subcategory_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Subcategory]:
        """Lista todas as subcategorys"""
        return session.query(Subcategory).offset(skip).limit(limit).all()

    def update(self, subcategory: Subcategory, session: Session) -> Subcategory:
        """Atualiza uma subcategory"""
        session.merge(subcategory)
        session.flush()
        return subcategory

    def delete(self, subcategory_id: int, session: Session) -> bool:
        """Deleta uma subcategory"""
        subcategory = self.get_by_id(subcategory_id, session)
        if subcategory:
            session.delete(subcategory)
            session.flush()
            return True
        return False

    def get_by_name(self, name: str, session: Session) -> Optional[Subcategory]:
        """Busca subcategory por nome exato"""
        return session.query(Subcategory).filter(Subcategory.nome == name).first()

    def get_by_categoria(self, categoria_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Subcategory]:
        """Busca subcategorys por categoria"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Subcategory).filter(
            Subcategory.id_categoria == categoria_id
        ).offset(skip).limit(limit).all()

    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Subcategory]:
        """Busca subcategorys por nome (busca parcial)"""
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Subcategory).filter(
            Subcategory.nome.ilike(f"%{name.strip()}%")
        ).offset(skip).limit(limit).all()

    def exists_by_name(self, name: str, session: Session) -> bool:
        """Verifica se subcategory existe por nome"""
        from sqlalchemy import exists
        return session.query(exists().where(Subcategory.nome == name)).scalar()
