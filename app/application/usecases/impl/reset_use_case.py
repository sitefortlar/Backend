from fastapi import HTTPException, status

from app.application.service.hash_service import HashService
from app.application.usecases.use_case import UseCase
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.email_token_repository_interface import IEmailTokenRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl
from app.infrastructure.utils.validate_password import validate_password
from app.presentation.routers.request.reset_password_request import ResetPasswordRequest
from app.infrastructure.configs.database_config import Session

class ResetPasswordUseCase(UseCase[ResetPasswordRequest, None]):

    def __init__(self):
        self.company_repo: ICompanyRepository = CompanyRepositoryImpl()
        self.email_token_repo: IEmailTokenRepository = EmailTokenRepositoryImpl()
        self.hash_service: HashService = HashService()


    def execute(self, data: ResetPasswordRequest, session: Session = None) -> None:
        # valida token
        if not self.email_token_repo.exists_by_token_and_company_id_and_type(data.token,
                                                                             data.company_id,
                                                                             EmailTokenTypeEnum.RESET_SENHA,
                                                                             session):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Token inválido")

        # atualiza senha
        company = self.company_repo.get_by_id(data.company_id, session)
        if not company:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empresa não encontrada")

        if not validate_password(data.new_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Senha inválida. Deve ter no mínimo 8 caracteres, uma letra maiúscula, um número e um caractere especial."
            )

        # Hash da senha
        password_hash = self.hash_service.hash_password(data.new_password)

        self.company_repo.update_password(data.company_id, password_hash, session)

        # opcional: apagar token após uso
        self.email_token_repo.delete_by_token_and_company_id(data.token, data.company_id, session)

