"""Implementação do repository para Address"""

from typing import Optional, List

from app.domain.models.address_model import Address
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.address_repository_interface import IAddressRepository


class AddressRepositoryImpl(IAddressRepository):
    """Repository para operações de Address com CRUD completo"""

    # Implementação dos métodos abstratos do IAddressRepository
    def create(self, address: Address, session: Session) -> Address:
        """Cria um novo endereço"""
        session.add(address)
        session.flush()
        return address

    def get_by_id(self, address_id: int, session: Session) -> Optional[Address]:
        """Busca endereço por ID"""
        return session.query(Address).filter(Address.id_endereco == address_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Address]:
        """Lista todos os endereços"""
        return session.query(Address).offset(skip).limit(limit).all()

    def update(self, address: Address, session: Session) -> Address:
        """Atualiza um endereço"""
        session.merge(address)
        session.flush()
        return address

    def delete(self, address_id: int, session: Session) -> bool:
        """Deleta um endereço"""
        address = self.get_by_id(address_id, session)
        if address:
            session.delete(address)
            session.flush()
            return True
        return False

    def get_by_company(self, company_id: int, session: Session) -> List[Address]:
        """Busca endereços por empresa"""
        return session.query(Address).filter(Address.id_empresa == company_id).all()

    def get_by_cep(self, cep: str, session: Session) -> List[Address]:
        """Busca endereços por CEP"""
        return session.query(Address).filter(Address.cep == cep).all()

    def get_by_city(self, city: str, session: Session) -> List[Address]:
        """Busca endereços por cidade"""
        return session.query(Address).filter(Address.cidade.ilike(f"%{city}%")).all()

    def get_by_state(self, state: str, session: Session) -> List[Address]:
        """Busca endereços por estado (UF)"""
        return session.query(Address).filter(Address.uf == state.upper()).all()

    def get_primary_address(self, company_id: int, session: Session) -> Optional[Address]:
        """Busca endereço principal da empresa (primeiro endereço)"""
        return session.query(Address).filter(
            Address.id_empresa == company_id
        ).first()

    def search_by_address(self, address_parts: str, session: Session) -> List[Address]:
        """Busca endereços por partes do endereço (rua, bairro, etc.)"""
        return session.query(Address).filter(
            (Address.bairro.ilike(f"%{address_parts}%")) |
            (Address.cidade.ilike(f"%{address_parts}%")) |
            (Address.ibge.ilike(f"%{address_parts}%"))
        ).all()

    def get_by_ibge(self, ibge: str, session: Session) -> List[Address]:
        """Busca endereços por código IBGE"""
        return session.query(Address).filter(Address.ibge == ibge).all()
