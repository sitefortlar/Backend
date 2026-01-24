"""Exceções específicas do domínio de categorias"""

from app.application.exceptions.existing_record_exception import ExistingRecordException
from app.application.exceptions.not_found_record_exception import NotFoundRecordException


class CategoryAlreadyExistsException(ExistingRecordException):
    """Exceção lançada quando uma categoria já existe"""
    pass


class CategoryNotFoundException(NotFoundRecordException):
    """Exceção lançada quando uma categoria não é encontrada"""
    pass


class SubcategoryAlreadyExistsException(ExistingRecordException):
    """Exceção lançada quando uma subcategoria já existe"""
    pass


class SubcategoryNotFoundException(NotFoundRecordException):
    """Exceção lançada quando uma subcategoria não é encontrada"""
    pass
