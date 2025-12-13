from fastapi import HTTPException, status
from app.application.service.hash_service import HashService
from app.application.service.jwt_service import JWTService
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.presentation.routers.request.login_request import LoginRequest
from app.presentation.routers.response.login_response import LoginResponse
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl

class LoginUseCase:
    def __init__(self):
        self.company_repo: ICompanyRepository = CompanyRepositoryImpl()
        self.hash_service: HashService = HashService()
        self.jwt_service: JWTService = JWTService()

    def execute(self, request: LoginRequest, session: Session = None) -> LoginResponse:
        company = self.__valid_company(request.login, session)
        self.__valid_password(request.password, company.senha_hash)

        # Gera token JWT
        token = self.jwt_service.generate_token({
            "sub": str(company.id_empresa),
            "email": company.contatos[0].email if company.contatos else company.email,
            "role": company.perfil.value  # Inclui a role no token
        })

        return LoginResponse(access_token=token)


    def __valid_company(self, login, session: Session = None ):
        company = self.company_repo.find_by_email_or_cnpj(login,session)
        if not company:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciais inválidas")
        if not company.ativo:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Confirmacao de Email pendente")
        return company


    def __valid_password(self, password_request, password_company ):
        if not self.hash_service.verify_password(password_request, password_company ):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciais inválidas")