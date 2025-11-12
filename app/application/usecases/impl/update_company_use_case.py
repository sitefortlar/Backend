"""Use case para atualizar empresa"""

from typing import Dict, Any
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.company_model import Company
from app.domain.exceptions.company_exceptions import CompanyNotFoundException
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.presentation.routers.response.company_response import CompanyResponse


class UpdateCompanyUseCase(UseCase[Dict[str, Any], CompanyResponse]):
    """Use case para atualizar empresa"""

    def __init__(self, company_repository: ICompanyRepository):
        self.company_repository = company_repository

    def execute(self, request: Dict[str, Any], session=None) -> CompanyResponse:
        """Executa o caso de uso de atualização de empresa"""
        try:
            company_id = request.get('company_id')
            if not company_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID da empresa é obrigatório"
                )

            # Busca empresa existente
            company = self.company_repository.get_by_id(company_id, session)
            if not company:
                raise CompanyNotFoundException(f"Empresa com ID {company_id} não encontrada")

            # Atualiza campos permitidos
            self._update_company_fields(company, request)

            # Salva alterações
            updated_company = self.company_repository.update(company, session)

            return self._build_company_response(updated_company)

        except CompanyNotFoundException:
            raise
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao atualizar empresa: {str(e)}"
            )

    def _update_company_fields(self, company: Company, request: Dict[str, Any]) -> None:
        """Atualiza campos da empresa"""
        # Campos que podem ser atualizados
        updatable_fields = [
            'razao_social', 'nome_fantasia', 'ativo'
        ]

        for field in updatable_fields:
            if field in request:
                setattr(company, field, request[field])

    def _build_company_response(self, company: Company) -> CompanyResponse:
        """Constrói a resposta da empresa"""
        from app.presentation.routers.response.company_response import AddressResponse, ContactResponse

        # Converte endereços
        address_responses = [
            AddressResponse(
                id_endereco=addr.id_endereco,
                cep=addr.cep,
                numero=addr.numero,
                complemento=addr.complemento,
                bairro=addr.bairro,
                cidade=addr.cidade,
                uf=addr.uf,
                ibge=addr.ibge
            ) for addr in company.enderecos
        ]

        # Converte contatos
        contact_responses = [
            ContactResponse(
                id_contato=contact.id_contato,
                nome=contact.nome,
                telefone=contact.telefone,
                celular=contact.celular,
                email=contact.email
            ) for contact in company.contatos
        ]

        return CompanyResponse(
            id_empresa=company.id_empresa,
            cnpj=company.cnpj,
            razao_social=company.razao_social,
            nome_fantasia=company.nome_fantasia,
            perfil=company.perfil.value,
            ativo=company.ativo,
            created_at=company.created_at,
            updated_at=company.updated_at,
            enderecos=address_responses,
            contatos=contact_responses
        )
