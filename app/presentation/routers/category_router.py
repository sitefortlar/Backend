"""Router para operações de Categorias"""

from fastapi import APIRouter, Depends, HTTPException, Query, Path
from typing import List, Optional
from loguru import logger

# Use Cases
from app.application.usecases.impl.create_category_use_case import CreateCategoryUseCase
from app.application.usecases.impl.list_categories_use_case import ListCategoriesUseCase
from app.application.usecases.impl.get_category_use_case import GetCategoryUseCase
from app.application.usecases.impl.update_category_use_case import UpdateCategoryUseCase
from app.application.usecases.impl.delete_category_use_case import DeleteCategoryUseCase
from app.application.usecases.impl.create_subcategory_use_case import CreateSubcategoryUseCase
from app.application.usecases.impl.update_subcategory_use_case import UpdateSubcategoryUseCase
from app.application.usecases.impl.delete_subcategory_use_case import DeleteSubcategoryUseCase

# Request/Response Models
from app.presentation.routers.request.category_request import CategoryRequest, SubcategoryRequest
from app.presentation.routers.response.category_response import CategoryResponse, SubcategoryResponse

# Exceptions
from app.domain.exceptions.category_exceptions import (
    CategoryNotFoundException,
    SubcategoryNotFoundException
)

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
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
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


# ========== ENDPOINTS DE CATEGORIAS ==========

@category_router.get(
    "/{category_id}",
    response_model=CategoryResponse,
    summary="Buscar categoria por ID",
    description="Busca uma categoria específica pelo ID"
)
async def get_category(
    category_id: int = Path(..., description="ID da categoria"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> CategoryResponse:
    """Busca categoria por ID"""
    try:
        logger.info(f'=== Getting category: {category_id} ===')
        use_case: GetCategoryUseCase = GetCategoryUseCase()
        return use_case.execute(category_id, session=session)
    except CategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao buscar categoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao buscar categoria: {str(e)}")


@category_router.put(
    "/{category_id}",
    response_model=CategoryResponse,
    summary="Atualizar categoria",
    description="Atualiza dados de uma categoria existente"
)
async def update_category(
    category_id: int = Path(..., description="ID da categoria"),
    category: CategoryRequest = ...,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> CategoryResponse:
    """Atualiza categoria"""
    try:
        logger.info(f'=== Updating category: {category_id} ===')
        use_case: UpdateCategoryUseCase = UpdateCategoryUseCase()
        request_data = {
            "category_id": category_id,
            "name": category.name
        }
        return use_case.execute(request_data, session=session)
    except CategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao atualizar categoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao atualizar categoria: {str(e)}")


@category_router.delete(
    "/{category_id}",
    status_code=204,
    summary="Deletar categoria",
    description="Remove uma categoria do sistema (deleta subcategorias em cascade)"
)
async def delete_category(
    category_id: int = Path(..., description="ID da categoria"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
):
    """Deleta categoria"""
    try:
        logger.info(f'=== Deleting category: {category_id} ===')
        use_case: DeleteCategoryUseCase = DeleteCategoryUseCase()
        use_case.execute(category_id, session=session)
        return None
    except CategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao deletar categoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao deletar categoria: {str(e)}")


# ========== ENDPOINTS DE SUBCATEGORIAS ==========

@category_router.post(
    "/{category_id}/subcategory",
    response_model=SubcategoryResponse,
    status_code=201,
    summary="Criar subcategoria",
    description="Cria uma nova subcategoria para uma categoria"
)
async def create_subcategory(
    category_id: int = Path(..., description="ID da categoria"),
    subcategory: SubcategoryRequest = ...,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> SubcategoryResponse:
    """Cria uma nova subcategoria"""
    try:
        logger.info(f'=== Creating subcategory for category: {category_id} ===')
        use_case: CreateSubcategoryUseCase = CreateSubcategoryUseCase()
        request_data = {
            "category_id": category_id,
            "name": subcategory.name
        }
        return use_case.execute(request_data, session=session)
    except CategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao criar subcategoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao criar subcategoria: {str(e)}")


@category_router.put(
    "/{category_id}/subcategory/{subcategory_id}",
    response_model=SubcategoryResponse,
    summary="Atualizar subcategoria",
    description="Atualiza dados de uma subcategoria existente"
)
async def update_subcategory(
    category_id: int = Path(..., description="ID da categoria"),
    subcategory_id: int = Path(..., description="ID da subcategoria"),
    subcategory: SubcategoryRequest = ...,
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
) -> SubcategoryResponse:
    """Atualiza subcategoria"""
    try:
        logger.info(f'=== Updating subcategory: {subcategory_id} ===')
        use_case: UpdateSubcategoryUseCase = UpdateSubcategoryUseCase()
        request_data = {
            "subcategory_id": subcategory_id,
            "name": subcategory.name
        }
        return use_case.execute(request_data, session=session)
    except SubcategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao atualizar subcategoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao atualizar subcategoria: {str(e)}")


@category_router.delete(
    "/{category_id}/subcategory/{subcategory_id}",
    status_code=204,
    summary="Deletar subcategoria",
    description="Remove uma subcategoria do sistema"
)
async def delete_subcategory(
    category_id: int = Path(..., description="ID da categoria"),
    subcategory_id: int = Path(..., description="ID da subcategoria"),
    session: Session = Depends(get_session),
    current_user = Depends(verify_user_permission(role=RoleEnum.ADMIN))
):
    """Deleta subcategoria"""
    try:
        logger.info(f'=== Deleting subcategory: {subcategory_id} ===')
        use_case: DeleteSubcategoryUseCase = DeleteSubcategoryUseCase()
        use_case.execute(subcategory_id, session=session)
        return None
    except SubcategoryNotFoundException as e:
        raise HTTPException(status_code=404, detail=e.message)
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao deletar subcategoria: {e}")
        raise HTTPException(status_code=500, detail=f"Erro ao deletar subcategoria: {str(e)}")

