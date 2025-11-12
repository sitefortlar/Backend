"""Interface do repository para Subcategory"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.subcategory_model import Subcategory
from app.infrastructure.configs.database_config import Session


class ISubcategoryRepository(ABC):
    """Interface para operações de Subcategory"""

    @abstractmethod
    def create(self, subcategoria: Subcategory, session: Session) -> Subcategory:
        pass

    @abstractmethod
    def get_by_id(self, subcategoria_id: int, session: Session) -> Optional[Subcategory]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Subcategory]:
        pass

    @abstractmethod
    def update(self, subcategoria: Subcategory, session: Session) -> Subcategory:
        pass

    @abstractmethod
    def delete(self, subcategoria_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_name(self, name: str, session: Session) -> Optional[Subcategory]:
        pass

    @abstractmethod
    def get_by_categoria(self, categoria_id: int, session: Session) -> List[Subcategory]:
        pass

    @abstractmethod
    def search_by_name(self, name: str, session: Session) -> List[Subcategory]:
        pass

    @abstractmethod
    def exists_by_name(self, name: str, session: Session) -> bool:
        pass
