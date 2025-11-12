"""Router para operações de Login - Refatorado com Clean Architecture e SOLID"""

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from loguru import logger

from app.application.usecases.impl.login_use_case import LoginUseCase
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
from app.presentation.routers.request.login_request import LoginRequest
from app.presentation.routers.response.login_response import LoginResponse

login_router = APIRouter(
    prefix="/auth",
    tags=["Autenticação"],
    responses={
        401: {"description": "Credenciais inválidas"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)




@login_router.post(
    "/login",
    summary="Login de empresa",
    description="Autentica empresa e retorna JWT",
    response_model=LoginResponse
)
def login(
    request: LoginRequest,
    session: Session = Depends(get_session)
) -> LoginResponse:
    """Endpoint para login de empresa"""
    try:
        logger.info('=== Realizando login ===')
        use_case: LoginUseCase = LoginUseCase()
        login_response = use_case.execute(request, session)
        return login_response
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro no login: {str(e)}")
