from typing import Optional, List
from sqlalchemy.orm import joinedload
from sqlalchemy import or_, and_

from app.domain.models.address_model import Address
from app.domain.models.company_model import Company
from app.domain.models.contact_model import Contact
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.company_repository_interface import ICompanyRepository


class CompanyRepositoryImpl(ICompanyRepository):
    """Repository para operações de Company com CRUD completo"""

    def exists_by_cnpj(self, cnpj: str, session: Session) -> bool:
        return session.query(Company).filter(Company.cnpj == cnpj).first() is not None

    def exists_by_email(self, email: str, session: Session) -> bool:
        return session.query(Company).join(Company.contatos).options(joinedload(Company.contatos)).filter(Contact.email == email).first() is not None

    def find_by_email_or_cnpj(self, login: str, session: Session) -> Optional[Company]:
        query = (
            session.query(Company)
            .join(Company.contatos)  
            .options(joinedload(Company.contatos))  
            .filter(
                or_(
                    Company.cnpj == login,
                    Contact.email == login
                )
            )
        )
        return query.first()

    def get_by_id(self, company_id: int, session: Session) -> Optional[Company]:
        return session.query(Company).filter(Company.id_empresa == company_id).first()

    def get_by_id_and_role(self, company_id: int, role, session: Session) -> Optional[Company]:
        return session.query(Company).filter(
            and_(Company.id_empresa == company_id, Company.perfil == role)
        ).first()

    def create_company_with_address_and_contact(self, company: Company, session: Session) -> int:
        session.add(company)
        session.flush()
        return company.id_empresa

    def update_company_ativo(self, company_id: int, session: Session) -> None:
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.ativo = True
            session.commit()


    def update_password(self, company_id: int, new_password: str, session: Session) -> None:
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.senha_hash = new_password
            session.commit()

    def update_company_ativo_status(self, company_id: int, ativo: bool, session: Session) -> None:
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.ativo = ativo
            session.commit()

    # Métodos CRUD específicos para Company
    def get_by_cnpj(self, cnpj: str, session: Session) -> Optional[Company]:
        """Busca empresa por CNPJ"""
        return session.query(Company).filter(Company.cnpj == cnpj).first()

    def get_by_email(self, email: str, session: Session) -> Optional[Company]:
        """Busca empresa por email do contato"""
        return session.query(Company).join(Company.contatos).filter(
            Contact.email == email
        ).first()

    def get_active_companies(self, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        """Busca empresas ativas"""
        return session.query(Company).filter(
            Company.ativo == True
        ).offset(skip).limit(limit).all()

    def get_by_vendedor(self, vendedor_id: int, session: Session) -> List[Company]:
        """Busca empresas por vendedor"""
        return session.query(Company).filter(
            Company.id_vendedor == vendedor_id
        ).all()

    def search_by_name(self, name: str, session: Session) -> List[Company]:
        """Busca empresas por nome (razao_social ou nome_fantasia)"""
        return session.query(Company).filter(
            or_(
                Company.razao_social.ilike(f"%{name}%"),
                Company.nome_fantasia.ilike(f"%{name}%")
            )
        ).all()

    def update_status(self, company_id: int, ativo: bool, session: Session) -> bool:
        """Atualiza status ativo/inativo da empresa"""
        company = self.get_by_id(company_id, session)
        if company:
            company.ativo = ativo
            session.commit()
            return True
        return False

    def get_with_relations(self, company_id: int, session: Session) -> Optional[Company]:
        """Busca empresa com todos os relacionamentos"""
        return session.query(Company).options(
            joinedload(Company.enderecos),
            joinedload(Company.contatos),
            joinedload(Company.vendedor)
        ).filter(Company.id_empresa == company_id).first()


