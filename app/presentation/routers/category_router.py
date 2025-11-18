"""Router para operações de Categorias"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from loguru import logger

# Use Cases
from app.application.usecases.impl.create_category_use_case import CreateCategoryUseCase
from app.application.usecases.impl.list_categories_use_case import ListCategoriesUseCase

# Request/Response Models
from app.presentation.routers.request.category_request import CategoryRequest
from app.presentation.routers.response.category_response import CategoryResponse

# Configs
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.security_config import verify_user_permission
from app.domain.models.enumerations.role_enumerations import RoleEnum

category_router = APIRouter(
    prefix="/category",
    tags=["Categorias"],
    responses={
        404: {"description": "Category não encontrada"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


# Dependency Injection Functions removidas - usando padrão simples


@category_router.post(
    "",
    response_model=CategoryResponse,
    status_code=201,
    summary="Create category",
    description="Creates a new category with subcategories"
)
async def create_category(
    category: CategoryRequest,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.CLIENTE))
) -> CategoryResponse:
    """Creates a new category with subcategories"""
    try:
        logger.info('=== Creating category ===')
        use_case: CreateCategoryUseCase = CreateCategoryUseCase()
        return use_case.execute(category, session=session)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating category: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating category: {str(e)}")


@category_router.get(
    "",
    summary="Listar categorias",
    description="Lista todas as categorias com suas subcategorias"
)
async def list_categories(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros"),
    search_name: Optional[str] = Query(None, description="Buscar por nome"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista categorias com suas subcategorias aninhadas"""
    try:
        logger.info('=== Listing categories ===')
        use_case: ListCategoriesUseCase = ListCategoriesUseCase()
        request_data = {
            "skip": skip,
            "limit": limit,
            "search_name": search_name
        }
        return use_case.execute(request_data, session=session)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao listar categorias: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao listar categorias: {str(e)}")


