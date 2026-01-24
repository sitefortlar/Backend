"""Use case para atualizar subcategoria"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import SubcategoryNotFoundException, SubcategoryAlreadyExistsException
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl
from app.presentation.routers.response.category_response import SubcategoryResponse


class UpdateSubcategoryUseCase(UseCase[Dict[str, Any], SubcategoryResponse]):
    """Use case para atualizar subcategoria"""

    def __init__(self):
        self.subcategory_repo: ISubcategoryRepository = SubcategoryRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> SubcategoryResponse:
        """Executa o caso de uso de atualização de subcategoria"""
        try:
            subcategory_id = request.get('subcategory_id')
            if not subcategory_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID da subcategoria é obrigatório"
                )

            # Busca subcategoria existente
            subcategory = self.subcategory_repo.get_by_id(subcategory_id, session)
            if not subcategory:
                raise SubcategoryNotFoundException(f"Subcategoria com ID {subcategory_id} não encontrada")

            # Valida se o novo nome já existe para a mesma categoria
            new_name = request.get('name')
            if new_name and new_name.strip() and new_name.strip() != subcategory.nome:
                existing_sub = self.subcategory_repo.get_by_name(new_name.strip(), session)
                if existing_sub and existing_sub.id_categoria == subcategory.id_categoria:
                    raise SubcategoryAlreadyExistsException(
                        f"Subcategoria '{new_name}' já existe para esta categoria"
                    )
                subcategory.nome = new_name.strip()

            # Atualiza subcategoria
            updated_subcategory = self.subcategory_repo.update(subcategory, session)

            logger.info(f"Subcategory updated: {updated_subcategory.id_subcategoria} - {updated_subcategory.nome}")

            return SubcategoryResponse(
                id_subcategoria=updated_subcategory.id_subcategoria,
                nome=updated_subcategory.nome,
                id_categoria=updated_subcategory.id_categoria,
                created_at=updated_subcategory.created_at,
                updated_at=updated_subcategory.updated_at
            )

        except (SubcategoryNotFoundException, SubcategoryAlreadyExistsException):
            raise
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao atualizar subcategoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao atualizar subcategoria: {str(e)}"
            )
