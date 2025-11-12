from fastapi import Request, Depends
from fastapi.security import HTTPBearer
from typing import  Optional

from app.application.service.jwt_service import JWTService
from app.application.usecases.impl.valid_header_use_case import ValidHeaderUseCase
from app.application.usecases.impl.verify_user_permission_use_case import VerifyUserPermissionUseCase
from app.domain.models.dtos.header_request_dto import HeaderRequestDTO
from app.domain.models.dtos.header_response_dto import HeaderResponseDTO
from app.domain.models.dtos.user_company_permission_dto import UserCompanyPermissionDTO
from app.domain.models.enumerations.role_enumerations import RoleEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session

jwt_service = JWTService(secret_key="sua_chave_secreta_aqui")
security = HTTPBearer()

def verify_user_permission(role: Optional[RoleEnum] = None):


    def wrapper(request: Request, session: Session = Depends(get_session)):
        use_case: ValidHeaderUseCase = ValidHeaderUseCase()
        header_request: HeaderRequestDTO = HeaderRequestDTO(request.headers)
        response: HeaderResponseDTO = use_case.execute(header_request, None)

        dto = UserCompanyPermissionDTO(
            role,
            response.authorization
        )

        return VerifyUserPermissionUseCase().execute(dto, session)

    return wrapper

