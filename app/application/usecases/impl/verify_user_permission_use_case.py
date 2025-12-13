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
        from loguru import logger
        
        dto_user_permission_dict = data.to_dict()

        try:
            token_data = self.__valid_token(dto_user_permission_dict['authorization'])

            company = self.__get_company(token_data, dto_user_permission_dict, session)
            
            if not company:
                logger.error(f"❌ Empresa não encontrada para ID: {token_data.get('sub')}")
                raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
            
            # Extrai a role do token JWT
            token_role_str = token_data.get('role')
            token_role = None
            if token_role_str:
                # Converte string para RoleEnum
                try:
                    token_role = RoleEnum(token_role_str) if isinstance(token_role_str, str) else token_role_str
                    logger.debug(f"🔑 Role do token: {token_role} (tipo: {type(token_role)})")
                except ValueError as e:
                    logger.error(f"❌ Erro ao converter role do token: {token_role_str} - {e}")
                    raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
            
            # Role esperada (passada como parâmetro no verify_user_permission)
            expected_role = dto_user_permission_dict.get('user_profile')
            logger.debug(f"🎯 Role esperada: {expected_role} (tipo: {type(expected_role)})")
            logger.debug(f"🏢 Role do banco: {company.perfil} (tipo: {type(company.perfil)})")
            
            # Verifica se a role do token corresponde à role esperada
            if expected_role:
                if not token_role:
                    logger.error(f"❌ Token não contém role")
                    raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
                
                # Compara usando .value para garantir comparação correta
                if token_role.value != expected_role.value:
                    logger.error(f"❌ Role do token ({token_role.value}) não corresponde à role esperada ({expected_role.value})")
                    raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
            
            # Verifica se a role do banco corresponde à role esperada (fonte da verdade)
            # A role do banco é a fonte da verdade, não a do token
            if expected_role and company.perfil.value != expected_role.value:
                logger.error(f"❌ Role do banco ({company.perfil.value}) não corresponde à role esperada ({expected_role.value})")
                raise HTTPException(status_code=401, detail=messages['msg_not_allowed_user'])
            
            # Verifica consistência entre token e banco (opcional, apenas para segurança)
            if token_role and company.perfil.value != token_role.value:
                logger.warning(f"⚠️ Role do banco ({company.perfil.value}) não corresponde à role do token ({token_role.value}) - token pode estar desatualizado")
            
            logger.info(f"✅ Permissão verificada com sucesso para empresa {company.id_empresa}")
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
