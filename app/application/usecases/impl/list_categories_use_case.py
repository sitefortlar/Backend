"""Use case para listar categorias com subcategorias"""

from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status
from loguru import logger
from sqlalchemy.orm import joinedload

from app.application.usecases.use_case import UseCase
from app.domain.models.category_model import Category
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.configs.database_config import Session


class ListCategoriesUseCase(UseCase[Dict[str, Any], List[Dict[str, Any]]]):
    """Use case para listar categorias com subcategorias"""

    def __init__(self):
        self.category_repository: ICategoryRepository = CategoryRepositoryImpl()

    def execute(self, request: Dict[str, Any], session: Session = None) -> List[Dict[str, Any]]:
        """Executa o caso de uso de listagem de categorias com subcategorias"""
        try:
            skip = request.get('skip', 0)
            limit = request.get('limit', 100)
            search_name = request.get('search_name')

            # Query com joinedload para carregar subcategorias de forma eficiente
            query = session.query(Category).options(joinedload(Category.subcategorias))
            
            if search_name:
                query = query.filter(Category.nome.ilike(f"%{search_name}%"))
            
            categorias = query.offset(skip).limit(limit).all()
            
            if categorias is None:
                categorias = []
            
            # Converte para DTOs de resposta
            return [self._build_category_response(category) for category in categorias]

        except Exception as e:
            logger.error(f"Erro ao listar categorias: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar categorias: {str(e)}"
            )

    def _build_category_response(self, category: Category) -> Dict[str, Any]:
        """Constrói a resposta da categoria com subcategorias"""
        return {
            "id_categoria": category.id_categoria,
            "nome": category.nome,
            "created_at": category.created_at.isoformat(),
            "updated_at": category.updated_at.isoformat(),
            "subcategorias": [
                {
                    "id_subcategoria": sub.id_subcategoria,
                    "nome": sub.nome,
                    "created_at": sub.created_at.isoformat(),
                    "updated_at": sub.updated_at.isoformat()
                }
                for sub in category.subcategorias
            ]
        }

