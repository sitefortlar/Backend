from sqlalchemy import Integer, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin


class Address(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Endereço"""
    __tablename__ = 'enderecos'

    id_endereco: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    id_empresa: Mapped[int] = mapped_column(
        Integer, 
        ForeignKey('empresas.id_empresa', ondelete='CASCADE'), 
        nullable=False
    )

    cep: Mapped[str] = mapped_column(String(20), nullable=False)
    numero: Mapped[str] = mapped_column(String(20), nullable=False)
    complemento: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    bairro: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    cidade: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    uf: Mapped[str] = mapped_column(String(2), nullable=False)
    ibge: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)

    # Relacionamento
    empresa: Mapped[Optional['Company']] = relationship('Company', back_populates='enderecos')

    def __init__(self, cep, numero, complemento=None, bairro=None, cidade=None, uf=None, ibge=None, id_empresa=None):
        self.cep = cep
        self.numero = numero
        self.complemento = complemento
        self.bairro = bairro
        self.cidade = cidade
        self.uf = uf
        self.ibge = ibge
        self.id_empresa = id_empresa
