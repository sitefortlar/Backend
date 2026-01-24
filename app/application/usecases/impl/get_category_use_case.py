"""Use case para buscar categoria por ID"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import CategoryNotFoundException
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.presentation.routers.response.category_response import CategoryResponse, SubcategoryResponse


def _build_category_response(category) -> CategoryResponse:
    """Builds the category response with subcategories"""
    subcategory_responses = [
        SubcategoryResponse(
            id_subcategoria=sub.id_subcategoria,
            nome=sub.nome,
            id_categoria=sub.id_categoria,
            created_at=sub.created_at,
            updated_at=sub.updated_at
        ) for sub in category.subcategorias
    ]

    return CategoryResponse(
        id_categoria=category.id_categoria,
        nome=category.nome,
        created_at=category.created_at,
        updated_at=category.updated_at,
        subcategorias=subcategory_responses
    )


class GetCategoryUseCase(UseCase[int, CategoryResponse]):
    """Use case para buscar categoria por ID"""

    def __init__(self):
        self.category_repo: ICategoryRepository = CategoryRepositoryImpl()

    def execute(self, category_id: int, session=None) -> CategoryResponse:
        """Executa o caso de uso de busca de categoria por ID"""
        try:
            category = self.category_repo.get_by_id(category_id, session)
            
            if not category:
                raise CategoryNotFoundException(f"Categoria com ID {category_id} não encontrada")

            logger.info(f"Category found: {category.id_categoria} - {category.nome}")
            return _build_category_response(category)

        except CategoryNotFoundException:
            raise
        except Exception as e:
            logger.error(f"Erro ao buscar categoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao buscar categoria: {str(e)}"
            )
