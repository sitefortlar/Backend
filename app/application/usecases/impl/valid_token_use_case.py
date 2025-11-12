from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.email_token_repository_interface import IEmailTokenRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl
from app.presentation.routers.request.validate_token_request import ValidateTokenRequest


class ValidTokenUseCase(UseCase[ValidateTokenRequest, None]):

    def __init__(self):
        self.company_repo: ICompanyRepository = CompanyRepositoryImpl()
        self.email_token_repo: IEmailTokenRepository = EmailTokenRepositoryImpl()

    def execute(self, data: ValidateTokenRequest, session: Session = None):
        self.__valid_token(data.token, data.company_id, session)
        self.__update_company(data.company_id, session)
        self.email_token_repo.delete_by_token_and_company_id(data.token, data.company_id, session)

        return dict(message="=== token successfully validated ===", id=data.company_id)

    def __valid_token(self, token, company_id, session):
        if not self.email_token_repo.exists_by_token_and_company_id_and_type(token,
                                                                             company_id,
                                                                             EmailTokenTypeEnum.VALIDACAO_EMAIL,
                                                                             session):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Token inválido")

    def __update_company(self, company_id, session):
        company = self.company_repo.get_by_id(company_id, session)
        if not company:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empresa não encontrada")

        self.company_repo.update_company_ativo(company_id, session)
