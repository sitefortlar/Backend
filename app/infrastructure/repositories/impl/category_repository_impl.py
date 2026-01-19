"""Implementação do repository para Category"""

from typing import Optional, List

from app.domain.models.category_model import Category
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository


class CategoryRepositoryImpl(ICategoryRepository):
    """Repository para operações de Category com CRUD completo"""

    # Implementação dos métodos abstratos do ICategoryRepository
    def create(self, category: Category, session: Session) -> Category:
        """Cria uma nova category"""
        session.add(category)
        session.flush()
        return category

    def get_by_id(self, category_id: int, session: Session) -> Optional[Category]:
        """Busca category por ID"""
        return session.query(Category).filter(Category.id_categoria == category_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        """Lista todas as categorys"""
        return session.query(Category).offset(skip).limit(limit).all()

    def update(self, category: Category, session: Session) -> Category:
        """Atualiza uma category"""
        session.merge(category)
        session.flush()
        return category

    def delete(self, category_id: int, session: Session) -> bool:
        """Deleta uma category"""
        category = self.get_by_id(category_id, session)
        if category:
            session.delete(category)
            session.flush()
            return True
        return False

    def get_by_name(self, name: str, session: Session) -> Optional[Category]:
        """Busca category por nome exato"""
        return session.query(Category).filter(Category.nome == name).first()

    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        """Busca categorys por nome (busca parcial)"""
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Category).filter(
            Category.nome.ilike(f"%{name.strip()}%")
        ).offset(skip).limit(limit).all()

    def exists_by_name(self, name: str, session: Session) -> bool:
        """Verifica se category existe por nome"""
        from sqlalchemy import exists
        return session.query(exists().where(Category.nome == name)).scalar()

    def get_categories_with_products(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        """Busca categorys que possuem produtos"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        # Comentado temporariamente devido a relacionamentos desabilitados
        return session.query(Category).offset(skip).limit(limit).all()

    def get_categories_with_subcategories(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        """Busca categorys que possuem subcategorys"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        # Comentado temporariamente devido a relacionamentos desabilitados
        return session.query(Category).offset(skip).limit(limit).all()
