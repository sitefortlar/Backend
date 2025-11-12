from abc import ABC, abstractmethod


class ICEPProvider(ABC):

    @abstractmethod
    async def get_address(self, cep: str):
        pass

