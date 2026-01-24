"""Use case para atualizar categoria"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import CategoryNotFoundException, CategoryAlreadyExistsException
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


class UpdateCategoryUseCase(UseCase[Dict[str, Any], CategoryResponse]):
    """Use case para atualizar categoria"""

    def __init__(self):
        self.category_repo: ICategoryRepository = CategoryRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> CategoryResponse:
        """Executa o caso de uso de atualização de categoria"""
        try:
            category_id = request.get('category_id')
            if not category_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID da categoria é obrigatório"
                )

            # Busca categoria existente
            category = self.category_repo.get_by_id(category_id, session)
            if not category:
                raise CategoryNotFoundException(f"Categoria com ID {category_id} não encontrada")

            # Valida se o novo nome já existe (se estiver sendo alterado)
            new_name = request.get('name')
            if new_name and new_name != category.nome:
                if self.category_repo.exists_by_name(new_name, session):
                    raise CategoryAlreadyExistsException(f"Categoria com nome '{new_name}' já existe")

            # Atualiza campos
            if new_name:
                category.nome = new_name

            # Salva alterações
            updated_category = self.category_repo.update(category, session)
            session.refresh(updated_category)

            logger.info(f"Category updated: {updated_category.id_categoria} - {updated_category.nome}")
            return _build_category_response(updated_category)

        except (CategoryNotFoundException, CategoryAlreadyExistsException):
            raise
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao atualizar categoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao atualizar categoria: {str(e)}"
            )
