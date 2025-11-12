"""Router para operações de Senha - Refatorado com Clean Architecture e SOLID"""

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

# Use Cases
from app.application.usecases.impl.forgot_use_case import ForgotPasswordUseCase
from app.application.usecases.impl.reset_use_case import ResetPasswordUseCase

# Services
from app.application.service.hash_service import HashService
from app.application.service.email_service import EmailService

# Repositories
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl

# Configs
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.database_config import Session

# DTOs
from app.presentation.routers.request.forgot_password_request import ForgotPasswordRequest
from app.presentation.routers.request.reset_password_request import ResetPasswordRequest


password_router = APIRouter(
    prefix="/password",
    tags=["Autenticação"],
    responses={
        400: {"description": "Dados inválidos"},
        404: {"description": "Token não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)




@password_router.post(
    "/forgot-password",
    summary="Esqueci minha senha",
    description="Envia email com instruções para redefinir senha"
)
def forgot_password(
    request: ForgotPasswordRequest, 
    session: Session = Depends(get_session)
):
    """
    Endpoint para solicitar redefinição de senha.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ForgotPasswordUseCase = ForgotPasswordUseCase()
        use_case.execute(request, session)
        return JSONResponse(
            content={"message": "Se um e-mail válido foi encontrado, enviamos instruções de recuperação."}, 
            status_code=200
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao processar solicitação: {str(e)}")


@password_router.post(
    "/reset-password",
    summary="Redefinir senha",
    description="Redefine a senha usando token de validação"
)
def reset_password(
    request: ResetPasswordRequest, 
    session: Session = Depends(get_session)
):
    """
    Endpoint para redefinir senha com token.
    
    Aplica os princípios SOLID:
    - Single Responsibility: Endpoint apenas orquestra a chamada do use case
    - Dependency Inversion: Depende de abstrações (use case) não de implementações
    """
    try:
        use_case: ResetPasswordUseCase = ResetPasswordUseCase()
        use_case.execute(request, session)
        return JSONResponse(
            content={"message": "Senha alterada com sucesso!"}, 
            status_code=200
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao redefinir senha: {str(e)}")
