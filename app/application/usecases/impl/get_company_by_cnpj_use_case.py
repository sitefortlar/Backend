from app.infrastructure.providers.cnpj_provider_interface import ICNPJProvider
from app.infrastructure.providers.impl.cnpj_provider_impl import CNPJProviderImpl


class GetCompanyByCnpjUseCase:
    def __init__(self):
        self.cnpj_provider: ICNPJProvider = CNPJProviderImpl()

    async def execute(self, cnpj: str) -> dict:
        return await self.cnpj_provider.get_company_data(cnpj)
