from fastapi import HTTPException

from app.application.usecases.use_case import UseCase
from app.domain.models.dtos.header_request_dto import HeaderRequestDTO
from app.domain.models.dtos.header_response_dto import HeaderResponseDTO

from app.infrastructure.configs.database_config import Session
from app.infrastructure.utils.messages import messages


class ValidHeaderUseCase(UseCase[HeaderRequestDTO, HeaderResponseDTO]):


    def execute(self, data: HeaderRequestDTO, session: Session = None) -> HeaderResponseDTO:
        authorization = data.headers.get('Authorization')

        if not authorization or not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail=messages['msg_token_is_missing'])

        return HeaderResponseDTO(authorization)


