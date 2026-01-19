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
        """Verifica se empresa existe por CNPJ"""
        from sqlalchemy import exists
        return session.query(exists().where(Company.cnpj == cnpj)).scalar()

    def exists_by_email(self, email: str, session: Session) -> bool:
        """Verifica se empresa existe por email do contato"""
        from sqlalchemy import exists
        return session.query(
            exists().where(Contact.email == email).where(Contact.id_empresa == Company.id_empresa)
        ).scalar()

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
        """Busca empresa por ID"""
        return session.query(Company).options(
            joinedload(Company.enderecos),
            joinedload(Company.contatos),
            joinedload(Company.vendedor)
        ).filter(Company.id_empresa == company_id).first()

    def get_by_id_and_role(self, company_id: int, role, session: Session) -> Optional[Company]:
        return session.query(Company).filter(
            and_(Company.id_empresa == company_id, Company.perfil == role)
        ).first()

    def create_company_with_address_and_contact(self, company: Company, session: Session) -> int:
        session.add(company)
        session.flush()
        return company.id_empresa

    def update_company_ativo(self, company_id: int, session: Session) -> None:
        """Atualiza status ativo da empresa para True"""
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.ativo = True
            session.flush()


    def update_password(self, company_id: int, new_password: str, session: Session) -> None:
        """Atualiza senha da empresa"""
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.senha_hash = new_password
            session.flush()

    def update_company_ativo_status(self, company_id: int, ativo: bool, session: Session) -> None:
        """Atualiza status ativo/inativo da empresa"""
        company = session.query(Company).filter(Company.id_empresa == company_id).first()
        if company:
            company.ativo = ativo
            session.flush()

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

    def get_by_vendedor(self, vendedor_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        """Busca empresas por vendedor"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Company).options(
            joinedload(Company.enderecos),
            joinedload(Company.contatos),
            joinedload(Company.vendedor)
        ).filter(
            Company.id_vendedor == vendedor_id
        ).offset(skip).limit(limit).all()

    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        """Busca empresas por nome (razao_social ou nome_fantasia)"""
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Company).options(
            joinedload(Company.enderecos),
            joinedload(Company.contatos),
            joinedload(Company.vendedor)
        ).filter(
            or_(
                Company.razao_social.ilike(f"%{name.strip()}%"),
                Company.nome_fantasia.ilike(f"%{name.strip()}%")
            )
        ).offset(skip).limit(limit).all()

    def update_status(self, company_id: int, ativo: bool, session: Session) -> bool:
        """Atualiza status ativo/inativo da empresa"""
        company = self.get_by_id(company_id, session)
        if company:
            company.ativo = ativo
            session.flush()
            return True
        return False

    def get_with_relations(self, company_id: int, session: Session) -> Optional[Company]:
        """Busca empresa com todos os relacionamentos"""
        return session.query(Company).options(
            joinedload(Company.enderecos),
            joinedload(Company.contatos),
            joinedload(Company.vendedor)
        ).filter(Company.id_empresa == company_id).first()


