"""Interface do repository para Region"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.regions_model import Regions
from app.infrastructure.configs.database_config import Session


class IRegionRepository(ABC):
    """Interface para operações de Region"""

    @abstractmethod
    def create(self, region: Regions, session: Session) -> Regions:
        pass

    @abstractmethod
    def get_by_id(self, region_id: int, session: Session) -> Optional[Regions]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Regions]:
        pass

    @abstractmethod
    def update(self, region: Regions, session: Session) -> Regions:
        pass

    @abstractmethod
    def delete(self, region_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_estado(self, estado: str, session: Session) -> Optional[Regions]:
        pass

    @abstractmethod
    def exists_by_estado(self, estado: str, session: Session) -> bool:
        pass

