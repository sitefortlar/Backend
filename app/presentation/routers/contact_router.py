"""Router para operações de Contatos"""

from fastapi import APIRouter, Depends, HTTPException, Query, Path
from fastapi.responses import JSONResponse
from typing import List, Optional

from app.infrastructure.configs.database_config import Session
from app.infrastructure.configs.session_config import get_session
# Repositories
from app.infrastructure.repositories.impl.contact_repository_impl import ContactRepositoryImpl

contact_router = APIRouter(
    prefix="/contatos",
    tags=["Contatos"],
    responses={
        404: {"description": "Contato não encontrado"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@contact_router.get(
    "/",
    summary="Listar contatos",
    description="Lista todos os contatos com filtros opcionais"
)
async def list_contatos(
    skip: int = Query(0, ge=0, description="Número de registros para pular"),
    limit: int = Query(100, ge=1, le=1000, description="Número máximo de registros"),
    empresa_id: Optional[int] = Query(None, description="Filtrar por empresa"),
    search_name: Optional[str] = Query(None, description="Buscar por nome"),
    email: Optional[str] = Query(None, description="Filtrar por email"),
    phone: Optional[str] = Query(None, description="Filtrar por telefone"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista contatos com filtros opcionais"""
    try:
        contact_repo = ContactRepositoryImpl()
        
        if empresa_id:
            contatos = contact_repo.get_by_company(empresa_id, session)
        elif search_name:
            contatos = contact_repo.search_by_name(search_name, session)
        elif email:
            contato = contact_repo.get_by_email(email, session)
            contatos = [contato] if contato else []
        elif phone:
            contatos = contact_repo.get_by_phone(phone, session)
        else:
            contatos = contact_repo.get_all(session, skip, limit)
        
        # Debug: verificar se contatos é None
        if contatos is None:
            contatos = []
        
        return [
            {
                "id": cont.id_contato,
                "id_empresa": cont.id_empresa,
                "nome": cont.nome,
                "telefone": cont.telefone,
                "celular": cont.celular,
                "email": cont.email,
                "created_at": cont.created_at.isoformat(),
                "updated_at": cont.updated_at.isoformat()
            }
            for cont in contatos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar contatos: {str(e)}")


@contact_router.get(
    "/{contato_id}",
    summary="Buscar contato por ID",
    description="Busca um contato específico pelo ID"
)
async def get_contato(
    contato_id: int = Path(..., description="ID do contato"),
    session: Session = Depends(get_session)
) -> dict:
    """Busca contato por ID"""
    try:
        contact_repo = ContactRepositoryImpl()
        contato = contact_repo.get_by_id(contato_id, session)
        
        if not contato:
            raise HTTPException(status_code=404, detail="Contato não encontrado")
        
        return {
            "id": contato.id_contato,
            "id_empresa": contato.id_empresa,
            "nome": contato.nome,
            "telefone": contato.telefone,
            "celular": contato.celular,
            "email": contato.email,
            "created_at": contato.created_at.isoformat(),
            "updated_at": contato.updated_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar contato: {str(e)}")


@contact_router.get(
    "/empresa/{empresa_id}",
    summary="Listar contatos da empresa",
    description="Lista todos os contatos de uma empresa específica"
)
async def list_contatos_by_empresa(
    empresa_id: int = Path(..., description="ID da empresa"),
    session: Session = Depends(get_session)
) -> List[dict]:
    """Lista contatos de uma empresa"""
    try:
        contact_repo = ContactRepositoryImpl()
        contatos = contact_repo.get_by_company(empresa_id, session)
        
        return [
            {
                "id": cont.id_contato,
                "id_empresa": cont.id_empresa,
                "nome": cont.nome,
                "telefone": cont.telefone,
                "celular": cont.celular,
                "email": cont.email,
                "created_at": cont.created_at.isoformat(),
                "updated_at": cont.updated_at.isoformat()
            }
            for cont in contatos
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar contatos da empresa: {str(e)}")


@contact_router.get(
    "/email/{email}",
    summary="Buscar contato por email",
    description="Busca um contato específico pelo email"
)
async def get_contato_by_email(
    email: str = Path(..., description="Email do contato"),
    session: Session = Depends(get_session)
) -> dict:
    """Busca contato por email"""
    try:
        contact_repo = ContactRepositoryImpl()
        contato = contact_repo.get_by_email(email, session)
        
        if not contato:
            raise HTTPException(status_code=404, detail="Contato não encontrado")
        
        return {
            "id": contato.id_contato,
            "id_empresa": contato.id_empresa,
            "nome": contato.nome,
            "telefone": contato.telefone,
            "celular": contato.celular,
            "email": contato.email,
            "created_at": contato.created_at.isoformat(),
            "updated_at": contato.updated_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar contato por email: {str(e)}")


@contact_router.get(
    "/empresa/{empresa_id}/principal",
    summary="Buscar contato principal da empresa",
    description="Busca o contato principal de uma empresa"
)
async def get_contato_principal(
    empresa_id: int = Path(..., description="ID da empresa"),
    session: Session = Depends(get_session)
) -> dict:
    """Busca contato principal da empresa"""
    try:
        contact_repo = ContactRepositoryImpl()
        contato = contact_repo.get_primary_contact(empresa_id, session)
        
        if not contato:
            raise HTTPException(status_code=404, detail="Contato principal não encontrado")
        
        return {
            "id": contato.id_contato,
            "id_empresa": contato.id_empresa,
            "nome": contato.nome,
            "telefone": contato.telefone,
            "celular": contato.celular,
            "email": contato.email,
            "created_at": contato.created_at.isoformat(),
            "updated_at": contato.updated_at.isoformat()
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao buscar contato principal: {str(e)}")
