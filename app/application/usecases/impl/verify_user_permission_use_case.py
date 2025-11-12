from typing import Optional

import jwt
from fastapi import HTTPException
from jwt import ExpiredSignatureError, InvalidTokenError

import envs
from app.application.usecases.use_case import UseCase
from app.domain.models.dtos.company_mode_dtol import CompanyDTO
from app.domain.models.dtos.user_company_permission_dto import UserCompanyPermissionDTO
from app.domain.models.enumerations.role_enumerations import RoleEnum
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl

from app.infrastructure.utils.messages import messages


class VerifyUserPermissionUseCase(UseCase[UserCompanyPermissionDTO, Optional[CompanyDTO]]):

    def __init__(self):
        self.__company_repository: ICompanyRepository = CompanyRepositoryImpl()


    def execute(self, data: UserCompanyPermissionDTO, session: Session = None) -> Optional[CompanyDTO]:
        dto_user_permission_dict = data.to_dict()

        try:
            data = self.__valid_token(dto_user_permission_dict['authorization'])

            company = self.__get_company(data, dto_user_permission_dict, session)
            if (
                    not company or
                    (company.perfil == RoleEnum.CLIENTE and
                     dto_user_permission_dict.get('user_profile') != RoleEnum.CLIENTE)
            ):
                raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
            return CompanyDTO(company.id_empresa, company.nome_fantasia, company.perfil)

        except ExpiredSignatureError:
            raise HTTPException(status_code=401, detail=messages['msg_token_is_invalid_or_expired'])
        except InvalidTokenError:
            raise HTTPException(status_code=401, detail=messages['msg_token_is_invalid_or_expired'])

    def __get_company(self, data, dto_user_permission_dict, session):

        company = self.__company_repository.get_by_id(company_id=int(data['sub']), session=session)
        return company




    @staticmethod
    def __valid_token(authorization):
        token = authorization.replace("Bearer ", "")
        return jwt.decode(jwt=token, key=envs.JWT_SECRET_KEY, algorithms=["HS256"])
