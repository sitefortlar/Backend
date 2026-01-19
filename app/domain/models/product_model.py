from sqlalchemy import Integer, String, Text, Boolean, Numeric, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from typing import Optional, List
from decimal import Decimal

from app.infrastructure.configs.base_mixin import BaseMixin, Base, TimestampMixin

# Imports para relacionamentos (Product é "filho", usa strings nas relationships)


class Product(Base, TimestampMixin, BaseMixin):
    """Modelo de domínio para Product"""
    __tablename__ = 'produtos'

    id_produto: Mapped[int] = mapped_column(Integer, primary_key=True)
    codigo: Mapped[str] = mapped_column(String(50), nullable=False, unique=True, index=True)
    nome: Mapped[str] = mapped_column(String(150), nullable=False)
    descricao: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    quantidade: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    cod_kit: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    id_categoria: Mapped[int] = mapped_column(Integer, ForeignKey('categoria.id_categoria'), nullable=False)
    id_subcategoria: Mapped[int] = mapped_column(Integer, ForeignKey('subcategoria.id_subcategoria'), nullable=True)
    valor_base: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    ativo: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    __table_args__ = (
        Index('idx_produto_nome', 'nome'),
        Index('idx_produto_cod_kit', 'cod_kit'),
        Index('idx_produto_ativo_categoria', 'ativo', 'id_categoria'),
        Index('idx_produto_valor_base', 'valor_base'),
        Index('idx_produto_categoria', 'id_categoria'),
        Index('idx_produto_subcategoria', 'id_subcategoria'),
    )

    # Relacionamentos
    categoria: Mapped[Optional['Category']] = relationship('Category', back_populates='produtos')
    subcategoria: Mapped[Optional['Subcategory']] = relationship('Subcategory', back_populates='produtos')
    imagens: Mapped[List['ProductImage']] = relationship(
        'ProductImage', 
        back_populates='produto', 
        cascade='all,delete-orphan'
    )
    itens_pedido: Mapped[List['OrderItem']] = relationship('OrderItem', back_populates='produto')


    def __init__(self, codigo, nome, id_categoria, id_subcategoria, valor_base, quantidade, cod_kit=None, descricao=None, ativo=True):
        self.codigo = codigo
        self.nome = nome
        self.descricao = descricao
        self.quantidade = quantidade
        self.cod_kit = cod_kit
        self.id_categoria = id_categoria
        self.id_subcategoria = id_subcategoria
        self.valor_base = valor_base
        self.ativo = ativo