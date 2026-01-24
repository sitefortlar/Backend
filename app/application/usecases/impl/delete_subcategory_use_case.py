"""Use case para deletar subcategoria"""

from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.category_exceptions import SubcategoryNotFoundException
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl


class DeleteSubcategoryUseCase(UseCase[int, bool]):
    """Use case para deletar subcategoria"""

    def __init__(self):
        self.subcategory_repo: ISubcategoryRepository = SubcategoryRepositoryImpl()

    def execute(self, subcategory_id: int, session=None) -> bool:
        """Executa o caso de uso de exclusão de subcategoria"""
        try:
            # Verifica se subcategoria existe
            subcategory = self.subcategory_repo.get_by_id(subcategory_id, session)
            if not subcategory:
                raise SubcategoryNotFoundException(f"Subcategoria com ID {subcategory_id} não encontrada")

            # Deleta subcategoria
            success = self.subcategory_repo.delete(subcategory_id, session)
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Erro ao deletar subcategoria"
                )

            logger.info(f"Subcategory deleted: {subcategory_id}")
            return True

        except SubcategoryNotFoundException:
            raise
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao deletar subcategoria: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao deletar subcategoria: {str(e)}"
            )
