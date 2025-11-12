"""Use case para listar empresas"""

from typing import List
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.company_model import Company
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.presentation.routers.response.company_response import CompanyResponse


class ListCompaniesUseCase(UseCase[dict, List[CompanyResponse]]):
    """Use case para listar empresas"""

    def __init__(self, company_repository: ICompanyRepository):
        self.company_repository = company_repository

    def execute(self, request: dict, session=None) -> List[CompanyResponse]:
        """Executa o caso de uso de listagem de empresas"""
        try:
            skip = request.get('skip', 0)
            limit = request.get('limit', 100)
            active_only = request.get('active_only', False)
            vendedor_id = request.get('vendedor_id')
            search_name = request.get('search_name')

            # Busca empresas baseado nos filtros
            if active_only:
                companies = self.company_repository.get_active_companies(session, skip, limit)
            elif vendedor_id:
                companies = self.company_repository.get_by_vendedor(vendedor_id, session)
            elif search_name:
                companies = self.company_repository.search_by_name(search_name, session)
            else:
                companies = self.company_repository.get_all(session, skip, limit)

            # Converte para DTOs de resposta
            return [self._build_company_response(company) for company in companies]

        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar empresas: {str(e)}"
            )

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
