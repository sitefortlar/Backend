"""Use case para deletar categoria"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import CategoryNotFoundException
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl


class DeleteCategoryUseCase(UseCase[int, bool]):
    """Use case para deletar categoria"""

    def __init__(self):
        self.category_repo: ICategoryRepository = CategoryRepositoryImpl()

    def execute(self, category_id: int, session=None) -> bool:
        """Executa o caso de uso de exclusão de categoria"""
        try:
            # Verifica se categoria existe
            category = self.category_repo.get_by_id(category_id, session)
            if not category:
                raise CategoryNotFoundException(f"Categoria com ID {category_id} não encontrada")

            # Deleta categoria (subcategorias serão deletadas em cascade)
            success = self.category_repo.delete(category_id, session)
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Erro ao deletar categoria"
                )

            logger.info(f"Category deleted: {category_id}")
            return True

        except CategoryNotFoundException:
            raise
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao deletar categoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao deletar categoria: {str(e)}"
            )
