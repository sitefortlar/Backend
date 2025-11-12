from typing import Optional

from app.domain.models.enumerations.role_enumerations import RoleEnum


class UserCompanyPermissionDTO:

    def __init__(self,
                 user_profile: Optional[RoleEnum] = None,
                 authorization: Optional[str] = None):
        self.__user_profile  = user_profile
        self.__authorization = authorization

    def to_dict(self):
        return {
            "user_profile": self.__user_profile,
            "authorization": self.__authorization
        }
