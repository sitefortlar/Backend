"""Use case for creating category with subcategories"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.category_model import Category
from app.domain.models.subcategory_model import Subcategory
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl
from app.presentation.routers.request.category_request import CategoryRequest
from app.presentation.routers.response.category_response import CategoryResponse, SubcategoryResponse


def _build_category_response(category) -> CategoryResponse:
    """Builds the category response with subcategories"""
    # Converte subcategorias
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


def _create_subcategory_entity(name: str, category_id: int) -> Subcategory:
    """Creates a Subcategory entity"""
    return Subcategory(
        nome=name,
        id_categoria=category_id
    )


class CreateCategoryUseCase(UseCase[CategoryRequest, CategoryResponse]):
    """Use case for creating category with subcategories"""

    def __init__(self):
        self.category_repo: ICategoryRepository = CategoryRepositoryImpl()
        self.subcategory_repo: ISubcategoryRepository = SubcategoryRepositoryImpl()

    def execute(self, request: CategoryRequest, session=None) -> CategoryResponse:
        """Executes the category creation use case"""
        self._validate_request(request, session)

        # Create category entity
        category = Category(nome=request.name)
        category = self.category_repo.create(category, session)
        logger.info(f"Category created: {category.id_categoria} - {category.nome}")

        # Create subcategories if provided (optional)
        if request.subcategory and len(request.subcategory) > 0:
            for subcat_request in request.subcategory:
                # Check if subcategory already exists for this category
                existing_sub = self.subcategory_repo.get_by_name(subcat_request.name, session)
                if existing_sub and existing_sub.id_categoria == category.id_categoria:
                    logger.warning(f"Subcategory '{subcat_request.name}' already exists, skipping")
                    continue

                # Create subcategory
                subcategory = _create_subcategory_entity(subcat_request.name, category.id_categoria)
                subcategory = self.subcategory_repo.create(subcategory, session)

                logger.info(f"Subcategory created: {subcategory.id_subcategoria} - {subcategory.nome}")

        # Refresh category to get updated subcategorias relationship
        session.refresh(category)

        # Return response
        return _build_category_response(category)

    def _validate_request(self, request: CategoryRequest, session) -> None:
        """Validates the request data"""
        if self.category_repo.exists_by_name(request.name, session=session):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=f"Category with name '{request.name}' already exists"
            )


