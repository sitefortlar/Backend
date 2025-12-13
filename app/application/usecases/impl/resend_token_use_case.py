from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.email_token_model import EmailToken
from app.domain.models.enumerations.email_token_type_enumerations import EmailTokenTypeEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.email_token_repository_interface import IEmailTokenRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl
from app.application.service.hash_service import HashService
from app.application.service.email_service import EmailService
from app.application.service.email.template.verification_template import verification
from app.presentation.routers.request.resend_token_request import ResendTokenRequest


class ResendTokenUseCase(UseCase[ResendTokenRequest, None]):

    def __init__(self):
        self.company_repo: ICompanyRepository = CompanyRepositoryImpl()
        self.email_token_repo: IEmailTokenRepository = EmailTokenRepositoryImpl()
        self.hash_service: HashService = HashService()
        self.email_service: EmailService = EmailService()

    def execute(self, data: ResendTokenRequest, session: Session = None):
        # Verifica se a empresa existe
        if data.company_id:
            company = self.company_repo.get_by_id(data.company_id, session)
        else:
            company = self.company_repo.find_by_email_or_cnpj(data.email.__str__(), session)

        if not company:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Empresa não encontrada")

        # Busca o email da empresa através do contato
        if not company.contatos or len(company.contatos) == 0:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Empresa não possui email cadastrado")

        email = company.contatos[0].email

        # Busca o token existente se houver
        existing_token = self.email_token_repo.get_by_company_id(company.id_empresa, session)
        if existing_token and existing_token.tipo != EmailTokenTypeEnum.VALIDACAO_EMAIL:
            existing_token = None

        token = self._send_verification_email(company.id_empresa, existing_token, email, session)
        
        # Faz commit explícito para garantir que o token foi salvo
        if session:
            session.commit()

        return dict(message="Token reenviado com sucesso", company_id=company.id_empresa, token=token)

    def _send_verification_email(self, company_id: int, email_token, email: str, session) -> str:
        """Envia email de verificação para a empresa"""
        # Remove token existente se houver
        if email_token:
            self.email_token_repo.delete_by_company_id_and_type(
                company_id,
                EmailTokenTypeEnum.VALIDACAO_EMAIL,
                session
            )
            session.flush()  # Garante que a deleção foi persistida

        token = self.hash_service.generate_email_token(company_id)

        # Cria token de email
        email_token = EmailToken(
            id_empresa=company_id,
            token=token,
            tipo=EmailTokenTypeEnum.VALIDACAO_EMAIL
        )

        # Persiste token primeiro (importante para não perder o token se email falhar)
        self.email_token_repo.create_email_token(email_token, session)
        session.flush()  # Garante que o token foi persistido antes de enviar o email
        
        # Tenta enviar email (não quebra a aplicação se falhar)
        try:
            # Gera HTML do email
            from urllib.parse import urlencode
            params = {
                'token': token,
                'companyId': str(company_id)
            }
            link = f"https://vendas.fortlar.com.br/confirmar-cadastro?{urlencode(params)}"
            html = verification(link, token)

            # Log para debug
            logger.info(f"🔗 Link de verificação gerado: {link}")
            logger.info(f"📧 Enviando email para {email} com companyId={company_id}")

            # Envia email (pode falhar na Render se SMTP estiver bloqueado)
            self.email_service.send_email(email, html, "Reenvio de Token de Validação")
            logger.info(f"✅ Email de reenvio de token enviado para {email}")
        except Exception as e:
            # Loga o erro mas não quebra a aplicação
            # O token já foi salvo, então o usuário pode solicitar reenvio novamente
            logger.error(f"❌ Erro ao enviar email de reenvio para {email}: {e}")
            logger.error(f"   Tipo do erro: {type(e).__name__}")
            logger.error(f"   Detalhes: {str(e)}")
            logger.info("💡 Token foi criado. O usuário pode solicitar reenvio novamente.")

        return token