"""Use case para criar subcategoria"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import CategoryNotFoundException, SubcategoryAlreadyExistsException
from app.domain.models.subcategory_model import Subcategory
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl
from app.presentation.routers.response.category_response import SubcategoryResponse


class CreateSubcategoryUseCase(UseCase[dict, SubcategoryResponse]):
    """Use case para criar subcategoria"""

    def __init__(self):
        self.category_repo: ICategoryRepository = CategoryRepositoryImpl()
        self.subcategory_repo: ISubcategoryRepository = SubcategoryRepositoryImpl()

    def execute(self, request: dict, session=None) -> SubcategoryResponse:
        """Executa o caso de uso de criação de subcategoria"""
        try:
            category_id = request.get('category_id')
            subcategory_name = request.get('name')

            if not category_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID da categoria é obrigatório"
                )

            if not subcategory_name or not subcategory_name.strip():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Nome da subcategoria é obrigatório"
                )

            # Verifica se categoria existe
            category = self.category_repo.get_by_id(category_id, session)
            if not category:
                raise CategoryNotFoundException(f"Categoria com ID {category_id} não encontrada")

            # Verifica se subcategoria já existe para esta categoria
            existing_sub = self.subcategory_repo.get_by_name(subcategory_name.strip(), session)
            if existing_sub and existing_sub.id_categoria == category_id:
                raise SubcategoryAlreadyExistsException(
                    f"Subcategoria '{subcategory_name}' já existe para esta categoria"
                )

            # Cria subcategoria
            subcategory = Subcategory(
                nome=subcategory_name.strip(),
                id_categoria=category_id
            )
            subcategory = self.subcategory_repo.create(subcategory, session)

            logger.info(f"Subcategory created: {subcategory.id_subcategoria} - {subcategory.nome}")

            return SubcategoryResponse(
                id_subcategoria=subcategory.id_subcategoria,
                nome=subcategory.nome,
                id_categoria=subcategory.id_categoria,
                created_at=subcategory.created_at,
                updated_at=subcategory.updated_at
            )

        except (CategoryNotFoundException, SubcategoryAlreadyExistsException):
            raise
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao criar subcategoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao criar subcategoria: {str(e)}"
            )
