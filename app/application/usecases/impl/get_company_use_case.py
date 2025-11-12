"""Use case para buscar empresa por ID"""

from typing import Optional
from fastapi import HTTPException, status

from app.application.usecases.use_case import UseCase
from app.domain.models.company_model import Company
from app.domain.exceptions.company_exceptions import CompanyNotFoundException
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.presentation.routers.response.company_response import CompanyResponse


class GetCompanyUseCase(UseCase[int, CompanyResponse]):
    """Use case para buscar empresa por ID"""

    def __init__(self):
        self.company_repository:ICompanyRepository = CompanyRepositoryImpl()

    def execute(self, company_id: int, session=None) -> CompanyResponse:
        """Executa o caso de uso de busca de empresa por ID"""
        try:
            # Busca empresa com relacionamentos
            company = self.company_repository.get_by_id(company_id, session)
            
            if not company:
                raise CompanyNotFoundException(f"Empresa com ID {company_id} não encontrada")

            return self._build_company_response(company)

        except CompanyNotFoundException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao buscar empresa: {str(e)}"
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
