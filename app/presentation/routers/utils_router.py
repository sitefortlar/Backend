from platform import system

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse

# Use Cases
from app.application.usecases.impl.get_address_by_cep_use_case import GetAddressByCepUseCase
from app.application.usecases.impl.get_company_by_cnpj_use_case import GetCompanyByCnpjUseCase

# Providers
from app.infrastructure.providers.impl.cep_provider_impl import CEPProviderImpl
from app.infrastructure.providers.impl.cnpj_provider_impl import CNPJProviderImpl

# Response Models
from app.presentation.routers.response.cep_response import CepResponse
from app.presentation.routers.response.cnpj_response import CnpjResponse

# Configs
from app.infrastructure.configs.session_config import get_session
from app.infrastructure.configs.database_config import Session

utils_router = APIRouter(
    prefix="/utils",
    tags=["Utilidades"],
    responses={
        400: {"description": "Dados inválidos"},
        404: {"description": "Não encontrado"},
        500: {"description": "Erro interno do servidor"}
    }
)



@utils_router.get(
    "/cep/{cep}",
    summary="Busca endereço por CEP",
    description="Consulta um CEP e retorna endereço, bairro, cidade e estado",
    response_model=CepResponse
)
async def get_address_by_cep(cep: str) -> CepResponse:
    try:
        use_case: GetAddressByCepUseCase = GetAddressByCepUseCase()
        result = await use_case.execute(cep)
        
        return CepResponse(**result)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao consultar CEP: {str(e)}")


@utils_router.get(
    "/cnpj/{cnpj}",
    summary="Busca dados da empresa por CNPJ",
    description="Consulta um CNPJ e retorna informações da empresa",
    response_model=CnpjResponse
)
async def get_company_by_cnpj(cnpj: str) -> CnpjResponse:
    try:
        use_case: GetCompanyByCnpjUseCase = GetCompanyByCnpjUseCase()
        result = await use_case.execute(cnpj)
        return CnpjResponse(**result)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao consultar CNPJ: {str(e)}")
