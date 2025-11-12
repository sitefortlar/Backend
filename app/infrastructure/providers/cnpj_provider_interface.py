from abc import ABC, abstractmethod


class ICNPJProvider(ABC):

    @abstractmethod
    async def get_company_data(self, cnpj: str):
        pass

