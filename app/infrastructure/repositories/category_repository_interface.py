"""Interface do repository para Category"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.category_model import Category
from app.infrastructure.configs.database_config import Session


class ICategoryRepository(ABC):
    """Interface para operações de Category"""

    @abstractmethod
    def create(self, categoria: Category, session: Session) -> Category:
        pass

    @abstractmethod
    def get_by_id(self, categoria_id: int, session: Session) -> Optional[Category]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        pass

    @abstractmethod
    def update(self, categoria: Category, session: Session) -> Category:
        pass

    @abstractmethod
    def delete(self, categoria_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_name(self, name: str, session: Session) -> Optional[Category]:
        pass

    @abstractmethod
    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        pass

    @abstractmethod
    def exists_by_name(self, name: str, session: Session) -> bool:
        pass

    @abstractmethod
    def get_categories_with_products(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        pass

    @abstractmethod
    def get_categories_with_subcategories(self, session: Session, skip: int = 0, limit: int = 100) -> List[Category]:
        pass
