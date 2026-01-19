from sqlalchemy import Integer, String, ForeignKey, Boolean, Enum, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import List, Optional

from app.domain.models.enumerations.role_enumerations import RoleEnum
from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos
from app.domain.models.address_model import Address
from app.domain.models.contact_model import Contact
from app.domain.models.email_token_model import EmailToken
from app.domain.models.seller_model import Seller


class Company(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Empresa"""
    __tablename__ = 'empresas'

    id_empresa: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    cnpj: Mapped[str] = mapped_column(String(20), nullable=False, unique=True, index=True)
    razao_social: Mapped[str] = mapped_column(String(255), nullable=False)
    nome_fantasia: Mapped[str] = mapped_column(String(255), nullable=False)
    senha_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    perfil: Mapped[RoleEnum] = mapped_column(
        Enum(RoleEnum, name="perfil_enum"), 
        nullable=False, 
        default=RoleEnum.CLIENTE
    )
    ativo: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    id_vendedor: Mapped[int] = mapped_column(Integer, ForeignKey('vendedor.id_vendedor'), nullable=False)

    __table_args__ = (
        Index('idx_empresa_razao_social', 'razao_social'),
        Index('idx_empresa_nome_fantasia', 'nome_fantasia'),
        Index('idx_empresa_ativo', 'ativo'),
        Index('idx_empresa_vendedor', 'id_vendedor'),
    )

    # Relacionamentos
    enderecos: Mapped[List['Address']] = relationship(
        'Address', 
        back_populates='empresa', 
        cascade='all,delete-orphan'
    )
    contatos: Mapped[List['Contact']] = relationship(
        'Contact', 
        back_populates='empresa', 
        cascade='all,delete-orphan'
    )
    email_token: Mapped[Optional['EmailToken']] = relationship('EmailToken', back_populates='empresa')

    vendedor: Mapped["Seller"] = relationship("Seller", back_populates="empresa")

    def __init__(self, cnpj, razao_social, nome_fantasia, senha_hash, id_vendedor, perfil=RoleEnum.CLIENTE, ativo=True):
        self.cnpj = cnpj
        self.razao_social = razao_social
        self.nome_fantasia = nome_fantasia
        self.senha_hash = senha_hash
        self.id_vendedor = id_vendedor
        self.perfil = perfil
        self.ativo = ativo
