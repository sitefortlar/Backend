from app.application.usecases.use_case import UseCase
from app.infrastructure.providers.cep_provider_interface import ICEPProvider
from app.infrastructure.providers.impl.cep_provider_impl import CEPProviderImpl


class GetAddressByCepUseCase(UseCase[str, dict]):
    def __init__(self):
        self.cep_provider: ICEPProvider = CEPProviderImpl()

    async def execute(self, cep: str) -> dict:
        return await self.cep_provider.get_address(cep)
