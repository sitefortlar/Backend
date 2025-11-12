import uuid
from fastapi import HTTPException, status

from app.application.service.email.template.reset_password_template import reset_password
from app.application.service.email_service import EmailService
from app.application.service.hash_service import HashService
from app.application.usecases.use_case import UseCase
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.email_token_repository_interface import IEmailTokenRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl
from app.presentation.routers.request.forgot_password_request import ForgotPasswordRequest
from app.domain.models.email_token_model import EmailToken
from app.infrastructure.configs.database_config import Session

class ForgotPasswordUseCase(UseCase[ForgotPasswordRequest, None]):

    def __init__(self):
        self.company_repo: ICompanyRepository = CompanyRepositoryImpl()
        self.email_token_repo: IEmailTokenRepository = EmailTokenRepositoryImpl()
        self.hash_service: HashService = HashService()
        self.email_service: EmailService = EmailService()

    def execute(self, data: ForgotPasswordRequest, session: Session = None) -> None:
        company = self.company_repo.find_by_email_or_cnpj(data.email.__str__(), session)

        if not company:
            return

        # Desativa a empresa para forçar redefinição de senha
        self.company_repo.update_company_ativo_status(company.id_empresa, False, session)

        # Gera token de reset
        token = self.hash_service.generate_email_token(company.id_empresa)

        # Remove tokens antigos de reset de senha para esta empresa
        self.email_token_repo.delete_by_company_id_and_type(
            company.id_empresa, 
            EmailTokenTypeEnum.RESET_SENHA, 
            session
        )

        # Cria novo token de email
        email_token = EmailToken(
            id_empresa=company.id_empresa,
            token=token,
            tipo=EmailTokenTypeEnum.RESET_SENHA
        )

        # Busca o email da empresa através do contato
        if company.contatos and len(company.contatos) > 0:
            email = company.contatos[0].email
            
            # Gera HTML do email
            html = reset_password("https://meusite.com/reset-password", token)
            
            # Envia email
            self.email_service.send_email(email, html, "Redefinição de Senha")

        # Persiste token no banco
        self.email_token_repo.create_email_token(email_token, session)
        session.commit()

        return dict(message="Email de redefinição de senha enviado com sucesso", company_id=company.id_empresa)
