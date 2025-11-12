"""Exceções específicas do domínio de empresas"""

from app.application.exceptions.existing_record_exception import ExistingRecordException
from app.application.exceptions.not_found_record_exception import NotFoundRecordException


class CompanyAlreadyExistsException(ExistingRecordException):
    """Exceção lançada quando uma empresa já existe"""
    pass


class CompanyNotFoundException(NotFoundRecordException):
    """Exceção lançada quando uma empresa não é encontrada"""
    pass


class CompanyInactiveException(Exception):
    """Exceção lançada quando uma empresa está inativa"""
    def __init__(self, message: str = "Empresa inativa"):
        self.message = message
        super().__init__(self.message)


class InvalidCompanyRoleException(Exception):
    """Exceção lançada quando o perfil da empresa é inválido para a operação"""
    def __init__(self, message: str = "Perfil de empresa inválido"):
        self.message = message
        super().__init__(self.message)
