import aiohttp
from loguru import logger
from app.infrastructure.providers.cnpj_provider_interface import ICNPJProvider

class CNPJProviderImpl(ICNPJProvider):
    """Consulta dados de CNPJ usando a BrasilAPI via requests diretos."""

    def __init__(self):
        self.base_url = "https://brasilapi.com.br/api/cnpj/v1"

    async def get_company_data(self, cnpj: str) -> dict:
        try:
            logger.info(f"Consultando dados da empresa para CNPJ {cnpj}")
            
            async with aiohttp.ClientSession() as session:
                async with session.get(f"{self.base_url}/{cnpj}") as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        return {
                            "cnpj": data.get("cnpj"),
                            "razao_social": data.get("razao_social"),
                            "fantasia": data.get("nome_fantasia"),
                            "cep": data.get("cep"),
                            "logradouro": data.get("logradouro"),
                            "numero": data.get("numero"),
                            "complemento": data.get("complemento"),
                            "bairro": data.get("bairro"),
                            "municipio": data.get("municipio"),
                            "uf": data.get("uf"),
                            "telefone": data.get("telefone"),
                            "email": data.get("email"),
                            "atividade_principal": data.get("atividade_principal")
                        }
                    else:
                        raise Exception(f"Erro na API: {response.status}")
                        
        except Exception as e:
            logger.error(f"Erro ao consultar CNPJ {cnpj}: {e}")
            raise Exception(f"Erro ao consultar CNPJ {cnpj}: {e}")
