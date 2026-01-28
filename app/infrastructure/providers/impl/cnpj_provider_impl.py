import asyncio
import json

import aiohttp
from aiohttp import ClientError, ClientTimeout
from loguru import logger
from fastapi import HTTPException
from app.infrastructure.providers.cnpj_provider_interface import ICNPJProvider
from app.infrastructure.utils.validate_cnpj import is_valid_cnpj, normalize_cnpj

class CNPJProviderImpl(ICNPJProvider):
    """Consulta dados de CNPJ usando a BrasilAPI via requests diretos."""

    def __init__(self):
        self.base_url = "https://brasilapi.com.br/api/cnpj/v1"

    async def get_company_data(self, cnpj: str) -> dict:
        try:
            cnpj_digits = normalize_cnpj(cnpj)
            if not is_valid_cnpj(cnpj_digits):
                raise HTTPException(status_code=422, detail="CNPJ inválido (informe 14 dígitos válidos)")

            url = f"{self.base_url}/{cnpj_digits}"
            logger.info(f"Consultando dados da empresa para CNPJ {cnpj_digits}")
            
            timeout = ClientTimeout(total=15)
            async with aiohttp.ClientSession(timeout=timeout) as session:
                async with session.get(url) as response:
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
                        # Tenta extrair mensagem retornada pela BrasilAPI
                        raw_text = await response.text()
                        message = None
                        try:
                            payload = json.loads(raw_text) if raw_text else {}
                            message = payload.get("message") if isinstance(payload, dict) else None
                        except Exception:
                            message = None

                        # Log detalhado para diagnóstico (status + body + URL)
                        logger.warning(
                            f"BrasilAPI CNPJ respondeu status={response.status} url={url} body={raw_text[:500]}"
                        )

                        if response.status == 404:
                            raise HTTPException(
                                status_code=404,
                                detail=message or f"CNPJ {cnpj_digits} não encontrado"
                            )

                        if response.status in (400, 422):
                            raise HTTPException(
                                status_code=422,
                                detail=message or "CNPJ inválido"
                            )

                        # Demais erros do serviço externo -> gateway
                        raise HTTPException(
                            status_code=502,
                            detail=f"Erro ao consultar serviço de CNPJ (status {response.status})"
                        )
                        
        except HTTPException:
            raise
        except (asyncio.TimeoutError, ClientError) as e:
            logger.error(f"Timeout/erro de rede ao consultar CNPJ {cnpj}: {e}")
            raise HTTPException(status_code=503, detail="Serviço de CNPJ indisponível no momento")
        except Exception as e:
            logger.error(f"Erro inesperado ao consultar CNPJ {cnpj}: {e}")
            raise HTTPException(status_code=500, detail="Erro interno ao consultar CNPJ")
