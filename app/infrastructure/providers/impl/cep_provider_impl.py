from loguru import logger
from brasilapi import BrasilAPI
from app.infrastructure.providers.cep_provider_interface import ICEPProvider

class CEPProviderImpl(ICEPProvider):
    """Realiza consultas de endereço a partir do CEP usando BrasilAPI."""

    def __init__(self):
        self._client = None

    @property
    def client(self):
        """Lazy initialization do cliente BrasilAPI"""
        if self._client is None:
            self._client = BrasilAPI()
        return self._client

    async def get_address(self, cep: str) -> dict:
        try:
            logger.info(f"Consultando endereço para CEP {cep}")
            address = await self.client.ceps.get(cep)

            return {
                "cep": address.cep,
                "logradouro": address.street,
                "complemento": None,
                "bairro": address.neighborhood,
                "cidade": address.city,
                "uf": address.state
            }
        except Exception as e:
            logger.error(f"Erro ao consultar CEP {cep}: {e}")
            raise Exception(f"Erro ao consultar CEP {cep}: {e}")
