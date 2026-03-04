import re
import aiohttp
from loguru import logger

from app.infrastructure.providers.cep_provider_interface import ICEPProvider


class CEPProviderImpl(ICEPProvider):
    """Consulta endereço por CEP usando a API pública BrasilAPI (HTTPS)."""

    BASE_URL = "https://brasilapi.com.br/api/cep/v1"

    async def get_address(self, cep: str) -> dict:
        cep_clean = re.sub(r"\D", "", cep)
        if len(cep_clean) != 8:
            raise ValueError(f"CEP inválido (deve ter 8 dígitos): {cep}")

        url = f"{self.BASE_URL}/{cep_clean}"
        try:
            logger.info(f"Consultando endereço para CEP {cep}")
            async with aiohttp.ClientSession() as session:
                async with session.get(url, timeout=aiohttp.ClientTimeout(total=10)) as resp:
                    if resp.status == 404:
                        raise Exception(f"CEP não encontrado: {cep}")
                    if resp.status != 200:
                        text = await resp.text()
                        raise Exception(f"BrasilAPI CEP respondeu {resp.status}: {text[:300]}")
                    data = await resp.json()

            return {
                "cep": data.get("cep", cep_clean),
                "logradouro": data.get("street") or "",
                "complemento": None,
                "bairro": data.get("neighborhood") or "",
                "cidade": data.get("city") or "",
                "uf": data.get("state") or "",
            }
        except aiohttp.ClientError as e:
            logger.error(f"Erro de rede ao consultar CEP {cep}: {e}")
            raise Exception(f"Erro ao consultar CEP: {str(e)}")
        except Exception as e:
            logger.error(f"Erro ao consultar CEP {cep}: {e}")
            raise
