"""Router para operações de Endereços"""

from fastapi import APIRouter, Depends, HTTPException, Query, Path
from typing import List, Optional

from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
# Repositories
from app.infrastructure.repositories.impl.address_repository_impl import AddressRepositoryImpl

address_router = APIRouter(
    prefix="/enderecos",
    tags=["Endereços"],
    responses={
        404: {"description": "Endereço não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@address_router.get(
    "",
    summary="Listar endereços",
    description="Lista todos os endereços com filtros opcionais"
)
async def list_enderecos(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros"),
    empresa_id: Optional[int] = Query(None, description="Filtrar por empresa"),
    cep: Optional[str] = Query(None, description="Filtrar por CEP"),
    cidade: Optional[str] = Query(None, description="Filtrar por cidade"),
    uf: Optional[str] = Query(None, description="Filtrar por estado (UF)"),
    ibge: Optional[str] = Query(None, description="Filtrar por código IBGE"),
    search_address: Optional[str] = Query(None, description="Buscar por partes do endereço"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista endereços com filtros opcionais"""
    try:
        address_repo = AddressRepositoryImpl()
        
        if empresa_id:
            enderecos = address_repo.get_by_company(empresa_id, session)
        elif cep:
            enderecos = address_repo.get_by_cep(cep, session)
        elif cidade:
            enderecos = address_repo.get_by_city(cidade, session)
        elif uf:
            enderecos = address_repo.get_by_state(uf, session)
        elif ibge:
            enderecos = address_repo.get_by_ibge(ibge, session)
        elif search_address:
            enderecos = address_repo.search_by_address(search_address, session)
        else:
            enderecos = address_repo.get_all(session, skip, limit)
        
        # Debug: verificar se enderecos é None
        if enderecos is None:
            enderecos = []
        
        return [
            {
                "id": end.id_endereco,
                "id_empresa": end.id_empresa,
                "cep": end.cep,
                "numero": end.numero,
                "complemento": end.complemento,
                "bairro": end.bairro,
                "cidade": end.cidade,
                "uf": end.uf,
                "ibge": end.ibge,
                "created_at": end.created_at.isoformat(),
                "updated_at": end.updated_at.isoformat()
            }
            for end in enderecos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar endereços: {str(e)}")


@address_router.get(
    "/{endereco_id}",
    summary="Buscar endereço por ID",
    description="Busca um endereço específico pelo ID"
)
async def get_endereco(
    endereco_id: int = Path(..., description="ID do endereço"),
    session: Session = Depends(get_session)
) -> dict:
    """Busca endereço por ID"""
    try:
        address_repo = AddressRepositoryImpl()
        endereco = address_repo.get_by_id(endereco_id, session)
        
        if not endereco:
            raise HTTPException(status_code=404, detail="Endereço não encontrado")
        
        return {
            "id": endereco.id_endereco,
            "id_empresa": endereco.id_empresa,
            "cep": endereco.cep,
            "numero": endereco.numero,
            "complemento": endereco.complemento,
            "bairro": endereco.bairro,
            "cidade": endereco.cidade,
            "uf": endereco.uf,
            "ibge": endereco.ibge,
            "created_at": endereco.created_at.isoformat(),
            "updated_at": endereco.updated_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar endereço: {str(e)}")


@address_router.get(
    "/empresa/{empresa_id}",
    summary="Listar endereços da empresa",
    description="Lista todos os endereços de uma empresa específica"
)
async def list_enderecos_by_empresa(
    empresa_id: int = Path(..., description="ID da empresa"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista endereços de uma empresa"""
    try:
        address_repo = AddressRepositoryImpl()
        enderecos = address_repo.get_by_company(empresa_id, session)
        
        return [
            {
                "id": end.id_endereco,
                "id_empresa": end.id_empresa,
                "cep": end.cep,
                "numero": end.numero,
                "complemento": end.complemento,
                "bairro": end.bairro,
                "cidade": end.cidade,
                "uf": end.uf,
                "ibge": end.ibge,
                "created_at": end.created_at.isoformat(),
                "updated_at": end.updated_at.isoformat()
            }
            for end in enderecos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar endereços da empresa: {str(e)}")


@address_router.get(
    "/empresa/{empresa_id}/principal",
    summary="Buscar endereço principal da empresa",
    description="Busca o endereço principal de uma empresa"
)
async def get_endereco_principal(
    empresa_id: int = Path(..., description="ID da empresa"),
    session: Session = Depends(get_session)
) -> dict:
    """Busca endereço principal da empresa"""
    try:
        address_repo = AddressRepositoryImpl()
        endereco = address_repo.get_primary_address(empresa_id, session)
        
        if not endereco:
            raise HTTPException(status_code=404, detail="Endereço principal não encontrado")
        
        return {
            "id": endereco.id_endereco,
            "id_empresa": endereco.id_empresa,
            "cep": endereco.cep,
            "numero": endereco.numero,
            "complemento": endereco.complemento,
            "bairro": endereco.bairro,
            "cidade": endereco.cidade,
            "uf": endereco.uf,
            "ibge": endereco.ibge,
            "created_at": endereco.created_at.isoformat(),
            "updated_at": endereco.updated_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar endereço principal: {str(e)}")


@address_router.get(
    "/cep/{cep}",
    summary="Listar endereços por CEP",
    description="Lista endereços de um CEP específico"
)
async def list_enderecos_by_cep(
    cep: str = Path(..., description="CEP"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista endereços por CEP"""
    try:
        address_repo = AddressRepositoryImpl()
        enderecos = address_repo.get_by_cep(cep, session)
        
        return [
            {
                "id": end.id_endereco,
                "id_empresa": end.id_empresa,
                "cep": end.cep,
                "numero": end.numero,
                "complemento": end.complemento,
                "bairro": end.bairro,
                "cidade": end.cidade,
                "uf": end.uf,
                "ibge": end.ibge,
                "created_at": end.created_at.isoformat(),
                "updated_at": end.updated_at.isoformat()
            }
            for end in enderecos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar endereços por CEP: {str(e)}")


@address_router.get(
    "/cidade/{cidade}",
    summary="Listar endereços por cidade",
    description="Lista endereços de uma cidade específica"
)
async def list_enderecos_by_cidade(
    cidade: str = Path(..., description="Nome da cidade"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista endereços por cidade"""
    try:
        address_repo = AddressRepositoryImpl()
        enderecos = address_repo.get_by_city(cidade, session)
        
        return [
            {
                "id": end.id_endereco,
                "id_empresa": end.id_empresa,
                "cep": end.cep,
                "numero": end.numero,
                "complemento": end.complemento,
                "bairro": end.bairro,
                "cidade": end.cidade,
                "uf": end.uf,
                "ibge": end.ibge,
                "created_at": end.created_at.isoformat(),
                "updated_at": end.updated_at.isoformat()
            }
            for end in enderecos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar endereços por cidade: {str(e)}")


@address_router.get(
    "/estado/{uf}",
    summary="Listar endereços por estado",
    description="Lista endereços de um estado específico"
)
async def list_enderecos_by_estado(
    uf: str = Path(..., description="Sigla do estado (UF)"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista endereços por estado"""
    try:
        address_repo = AddressRepositoryImpl()
        enderecos = address_repo.get_by_state(uf.upper(), session)
        
        return [
            {
                "id": end.id_endereco,
                "id_empresa": end.id_empresa,
                "cep": end.cep,
                "numero": end.numero,
                "complemento": end.complemento,
                "bairro": end.bairro,
                "cidade": end.cidade,
                "uf": end.uf,
                "ibge": end.ibge,
                "created_at": end.created_at.isoformat(),
                "updated_at": end.updated_at.isoformat()
            }
            for end in enderecos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar endereços por estado: {str(e)}")
