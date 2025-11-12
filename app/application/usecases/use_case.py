from abc import abstractmethod, ABC
from typing import TypeVar, Generic
from app.infrastructure.configs.database_config import Session

T = TypeVar('T')
K = TypeVar('K')


class UseCase(ABC, Generic[T, K]):

    @abstractmethod
    def execute(self, data: T, session: Session = None) -> K:
        pass
