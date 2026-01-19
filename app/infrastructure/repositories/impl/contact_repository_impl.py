"""Implementação do repository para Contact"""

from typing import Optional, List

from app.domain.models.contact_model import Contact
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.contact_repository_interface import IContactRepository


class ContactRepositoryImpl(IContactRepository):
    """Repository para operações de Contact com CRUD completo"""

    # Implementação dos métodos abstratos do IContactRepository
    def create(self, contact: Contact, session: Session) -> Contact:
        """Cria um novo contato"""
        session.add(contact)
        session.flush()
        return contact

    def get_by_id(self, contact_id: int, session: Session) -> Optional[Contact]:
        """Busca contato por ID"""
        return session.query(Contact).filter(Contact.id_contato == contact_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
        """Lista todos os contatos"""
        return session.query(Contact).offset(skip).limit(limit).all()

    def update(self, contact: Contact, session: Session) -> Contact:
        """Atualiza um contato"""
        session.merge(contact)
        session.flush()
        return contact

    def delete(self, contact_id: int, session: Session) -> bool:
        """Deleta um contato"""
        contact = self.get_by_id(contact_id, session)
        if contact:
            session.delete(contact)
            session.flush()
            return True
        return False

    def get_by_email(self, email: str, session: Session) -> Optional[Contact]:
        """Busca contato por email"""
        return session.query(Contact).filter(Contact.email == email).first()

    def get_by_company(self, company_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
        """Busca contatos por empresa"""
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Contact).filter(Contact.id_empresa == company_id).offset(skip).limit(limit).all()

    def exists_by_email(self, email: str, session: Session) -> bool:
        """Verifica se contato existe por email"""
        from sqlalchemy import exists
        return session.query(exists().where(Contact.email == email)).scalar()

    def get_primary_contact(self, company_id: int, session: Session) -> Optional[Contact]:
        """Busca contato principal da empresa (primeiro contato)"""
        return session.query(Contact).filter(
            Contact.id_empresa == company_id
        ).first()

    def search_by_name(self, name: str, session: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
        """Busca contatos por nome"""
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Contact).filter(
            Contact.nome.ilike(f"%{name.strip()}%")
        ).offset(skip).limit(limit).all()

    def get_by_phone(self, phone: str, session: Session, skip: int = 0, limit: int = 100) -> List[Contact]:
        """Busca contatos por telefone ou celular"""
        from sqlalchemy import or_
        
        # Validação de entrada
        if not phone or not phone.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        phone_clean = phone.strip()
        return session.query(Contact).filter(
            or_(Contact.telefone == phone_clean, Contact.celular == phone_clean)
        ).offset(skip).limit(limit).all()
