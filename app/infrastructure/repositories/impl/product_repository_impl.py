"""Implementação do repository para Product"""

from typing import Optional, List
from decimal import Decimal

from app.domain.models.product_model import Product
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.product_repository_interface import IProductRepository


class ProductRepositoryImpl(IProductRepository):
    """Repository para operações de Product com CRUD completo"""

    # Implementação dos métodos abstratos do IProductRepository
    def create(self, product: Product, session: Session) -> Product:
        """Cria um novo product"""
        session.add(product)
        session.flush()
        return product

    def get_by_id(self, product_id: int, session: Session) -> Optional[Product]:
        """Busca product por ID"""
        from sqlalchemy.orm import selectinload
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.id_produto == product_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Lista todos os products"""
        return session.query(Product).offset(skip).limit(limit).all()

    def update(self, product: Product, session: Session) -> Product:
        """Atualiza um product"""
        session.merge(product)
        session.flush()
        return product

    def delete(self, product_id: int, session: Session) -> bool:
        """Deleta um product"""
        product = self.get_by_id(product_id, session)
        if product:
            session.delete(product)
            session.flush()
            return True
        return False

    def get_by_codigo(self, codigo: str, session: Session) -> Optional[Product]:
        """Busca product por código"""
        # Garante que codigo seja string (pode vir como int do banco)
        codigo_str = str(codigo) if codigo is not None else None
        return session.query(Product).filter(Product.codigo == codigo_str).first()

    def get_by_categoria(self, categoria_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por categoria"""
        from sqlalchemy.orm import selectinload
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.id_categoria == categoria_id).offset(skip).limit(limit).all()

    def get_by_subcategoria(self, subcategoria_id: int, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por subcategoria"""
        from sqlalchemy.orm import selectinload
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.id_subcategoria == subcategoria_id).offset(skip).limit(limit).all()

    def get_active_products(self, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products ativos"""
        from sqlalchemy.orm import selectinload
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.ativo == True).offset(skip).limit(limit).all()

    def search_by_name(self, name: str, session: Session, exclude_kits: bool = False, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por nome"""
        from sqlalchemy import exists, or_, not_
        from sqlalchemy.orm import selectinload
        
        # Validação de entrada
        if not name or not name.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))  # Limite máximo de 1000
        
        query = session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.nome.ilike(f"%{name.strip()}%"))
        
        # Otimização: Filtragem de kits no SQL ao invés de Python
        if exclude_kits:
            # Filtra: produtos sem cod_kit OU produtos com cod_kit mas sem produto pai
            # Subquery verifica se existe produto com codigo igual ao cod_kit do produto atual
            from sqlalchemy import alias
            ProductParent = alias(Product.__table__)
            parent_exists = exists().select_from(ProductParent).where(
                ProductParent.c.codigo == Product.cod_kit
            )
            query = query.filter(
                or_(
                    Product.cod_kit.is_(None),
                    not_(parent_exists)
                )
            )
        
        return query.offset(skip).limit(limit).all()

    def get_by_price_range(self, min_price: Decimal, max_price: Decimal, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por faixa de preço"""
        from sqlalchemy.orm import selectinload
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(
            Product.valor_base.between(min_price, max_price)
        ).offset(skip).limit(limit).all()

    def search_by_description(self, description: str, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por descrição"""
        from sqlalchemy.orm import selectinload
        
        # Validação de entrada
        if not description or not description.strip():
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(
            Product.descricao.ilike(f"%{description.strip()}%")
        ).offset(skip).limit(limit).all()

    def get_products_with_images(self, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products que possuem imagens"""
        from sqlalchemy.orm import selectinload
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).join(Product.imagens).distinct().offset(skip).limit(limit).all()

    def update_status(self, product_id: int, ativo: bool, session: Session) -> bool:
        """Atualiza status ativo/inativo do product"""
        product = self.get_by_id(product_id, session)
        if product:
            product.ativo = ativo
            session.flush()
            return True
        return False

    def get_products_by_categories(self, categoria_ids: List[int], session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        """Busca products por múltiplas categorias"""
        from sqlalchemy.orm import selectinload
        
        # Validação de entrada
        if not categoria_ids:
            return []
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        return session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(
            Product.id_categoria.in_(categoria_ids)
        ).offset(skip).limit(limit).all()

    def get_all_with_filters(
        self, 
        session: Session,
        categoria_id: Optional[int] = None,
        subcategoria_id: Optional[int] = None,
        active_only: bool = True,
        order_by_price: Optional[str] = None,
        skip: int = 0,
        limit: Optional[int] = None,
        exclude_kits: bool = False
    ) -> List[Product]:
        """Busca produtos com filtros e ordenação. Se limit=None, retorna todos os registros"""
        from sqlalchemy import asc, desc, exists
        from sqlalchemy.orm import selectinload
        
        # Eager loading para evitar N+1 (categoria/subcategoria/imagens)
        query = session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens),
        )
        
        # Aplica filtros
        if active_only:
            query = query.filter(Product.ativo == True)
        
        if categoria_id is not None:
            query = query.filter(Product.id_categoria == categoria_id)
        
        if subcategoria_id is not None:
            query = query.filter(Product.id_subcategoria == subcategoria_id)
        
        # Aplica ordenação por preço
        if order_by_price:
            if order_by_price.upper() == 'ASC':
                query = query.order_by(asc(Product.valor_base))
            elif order_by_price.upper() == 'DESC':
                query = query.order_by(desc(Product.valor_base))
        else:
            # Ordenação padrão por ID
            query = query.order_by(Product.id_produto)
        
        # Validação de paginação
        skip = max(0, skip)
        if limit is not None:
            limit = max(1, min(limit, 1000))
        
        # Otimização: Filtragem de kits no SQL ao invés de Python
        if exclude_kits:
            # Filtra: produtos sem cod_kit OU produtos com cod_kit mas sem produto pai
            from sqlalchemy import exists, or_, not_, alias
            # Subquery verifica se existe produto com codigo igual ao cod_kit do produto atual
            ProductParent = alias(Product.__table__)
            parent_exists = exists().select_from(ProductParent).where(
                ProductParent.c.codigo == Product.cod_kit
            )
            query = query.filter(
                or_(
                    Product.cod_kit.is_(None),
                    not_(parent_exists)
                )
            )
        
        # Aplica skip
        if skip > 0:
            query = query.offset(skip)
        
        # Aplica limit apenas se fornecido
        if limit is not None:
            query = query.limit(limit)
        
        products = query.all()
        return products

    def get_by_cod_kit(self, cod_kit: str, exclude_product_id: Optional[int] = None, session: Session = None, skip: int = 0, limit: int = 100) -> List[Product]:
        """
        Busca produtos que pertencem a um kit.
        
        Parâmetro cod_kit: código do produto base (produto com cod_kit = null)
        Retorna: produtos onde cod_kit == cod_kit (itens que pertencem ao kit)
        
        Exemplo:
        - Produto base: codigo="9090", cod_kit=null
        - Itens do kit: cod_kit="9090"
        - Busca: get_by_cod_kit("9090") retorna todos os produtos com cod_kit="9090"
        """
        from sqlalchemy.orm import selectinload
        
        # Validação de paginação
        skip = max(0, skip)
        limit = max(1, min(limit, 1000))
        
        # Garante que cod_kit seja string (pode vir como int do banco)
        cod_kit_str = str(cod_kit) if cod_kit is not None else None
        query = session.query(Product).options(
            selectinload(Product.categoria),
            selectinload(Product.subcategoria),
            selectinload(Product.imagens)
        ).filter(Product.cod_kit == cod_kit_str)
        
        if exclude_product_id is not None:
            query = query.filter(Product.id_produto != exclude_product_id)
        
        return query.offset(skip).limit(limit).all()

    def get_by_ids(self, product_ids: List[int], session: Session) -> List[Product]:
        """Busca produtos por lista de IDs (em lote) com apenas os campos necessários para preço."""
        from sqlalchemy.orm import load_only

        if not product_ids:
            return []

        return (
            session.query(Product)
            .options(load_only(Product.id_produto, Product.codigo, Product.nome, Product.valor_base, Product.ativo))
            .filter(Product.id_produto.in_(product_ids))
            .all()
        )
