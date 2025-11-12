"""Use case para deletar empresa"""

from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.exceptions.company_exceptions import CompanyNotFoundException
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository


class DeleteCompanyUseCase(UseCase[int, bool]):
    """Use case para deletar empresa"""

    def __init__(self, company_repository: ICompanyRepository):
        self.company_repository = company_repository

    def execute(self, company_id: int, session=None) -> bool:
        """Executa o caso de uso de exclusão de empresa"""
        try:
            # Verifica se empresa existe
            company = self.company_repository.get_by_id(company_id, session)
            if not company:
                raise CompanyNotFoundException(f"Empresa com ID {company_id} não encontrada")

            # Deleta empresa
            success = self.company_repository.delete(company_id, session)
            
            if not success:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Erro ao deletar empresa"
                )

            return True

        except CompanyNotFoundException:
            raise
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao deletar empresa: {str(e)}"
            )
