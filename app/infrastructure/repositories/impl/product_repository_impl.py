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
        return session.query(Product).filter(Product.id_produto == product_id).first()

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

    def get_by_categoria(self, categoria_id: int, session: Session) -> List[Product]:
        """Busca products por categoria"""
        return session.query(Product).filter(Product.id_categoria == categoria_id).all()

    def get_by_subcategoria(self, subcategoria_id: int, session: Session) -> List[Product]:
        """Busca products por subcategoria"""
        return session.query(Product).filter(Product.id_subcategoria == subcategoria_id).all()

    def get_active_products(self, session: Session) -> List[Product]:
        """Busca products ativos"""
        return session.query(Product).filter(Product.ativo == True).all()

    def search_by_name(self, name: str, session: Session, exclude_kits: bool = False) -> List[Product]:
        """Busca products por nome"""
        from sqlalchemy import exists
        
        query = session.query(Product).filter(
            Product.nome.ilike(f"%{name}%")
        )
        
        # A filtragem de kits será feita após buscar os produtos para evitar problemas de tipo no PostgreSQL
        products = query.all()
        
        # Se exclude_kits, filtra produtos que têm cod_kit E têm produto pai correspondente
        if exclude_kits:
            filtered_products = []
            for product in products:
                # Se não tem cod_kit, inclui na lista
                if product.cod_kit is None:
                    filtered_products.append(product)
                else:
                    # Se tem cod_kit, verifica se existe produto pai
                    # Converte cod_kit para string (pode vir como int do banco)
                    cod_kit_str = str(product.cod_kit) if product.cod_kit is not None else None
                    if cod_kit_str:
                        parent = self.get_by_codigo(cod_kit_str, session)
                        # Só exclui se tiver produto pai (não inclui na lista)
                        # Se não tiver pai, inclui na lista
                        if not parent:
                            filtered_products.append(product)
                    else:
                        # Se cod_kit for None após conversão, inclui na lista
                        filtered_products.append(product)
            return filtered_products
        
        return products

    def get_by_price_range(self, min_price: Decimal, max_price: Decimal, session: Session) -> List[Product]:
        """Busca products por faixa de preço"""
        return session.query(Product).filter(
            Product.valor_base.between(min_price, max_price)
        ).all()

    def search_by_description(self, description: str, session: Session) -> List[Product]:
        """Busca products por descrição"""
        return session.query(Product).filter(
            Product.descricao.ilike(f"%{description}%")
        ).all()

    def get_products_with_images(self, session: Session) -> List[Product]:
        """Busca products que possuem imagens"""
        return session.query(Product).join(Product.imagens).distinct().all()

    def update_status(self, product_id: int, ativo: bool, session: Session) -> bool:
        """Atualiza status ativo/inativo do product"""
        product = self.get_by_id(product_id, session)
        if product:
            product.ativo = ativo
            session.commit()
            return True
        return False

    def get_products_by_categories(self, categoria_ids: List[int], session: Session) -> List[Product]:
        """Busca products por múltiplas categorias"""
        return session.query(Product).filter(
            Product.id_categoria.in_(categoria_ids)
        ).all()

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
        
        query = session.query(Product)
        
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
        
        # Aplica skip
        if skip > 0:
            query = query.offset(skip)
        
        # Aplica limit apenas se fornecido
        if limit is not None:
            query = query.limit(limit)
        
        # A filtragem de kits será feita após buscar os produtos para evitar problemas de tipo no PostgreSQL
        products = query.all()
        
        # Se exclude_kits, filtra produtos que têm cod_kit E têm produto pai correspondente
        if exclude_kits:
            filtered_products = []
            for product in products:
                # Se não tem cod_kit, inclui na lista
                if product.cod_kit is None:
                    filtered_products.append(product)
                else:
                    # Se tem cod_kit, verifica se existe produto pai
                    # Converte cod_kit para string (pode vir como int do banco)
                    cod_kit_str = str(product.cod_kit) if product.cod_kit is not None else None
                    if cod_kit_str:
                        parent = self.get_by_codigo(cod_kit_str, session)
                        # Só exclui se tiver produto pai (não inclui na lista)
                        # Se não tiver pai, inclui na lista
                        if not parent:
                            filtered_products.append(product)
                    else:
                        # Se cod_kit for None após conversão, inclui na lista
                        filtered_products.append(product)
            return filtered_products
        
        return products

    def get_by_cod_kit(self, cod_kit: str, exclude_product_id: Optional[int] = None, session: Session = None) -> List[Product]:
        """
        Busca produtos que pertencem a um kit.
        
        Parâmetro cod_kit: código do produto base (produto com cod_kit = null)
        Retorna: produtos onde cod_kit == cod_kit (itens que pertencem ao kit)
        
        Exemplo:
        - Produto base: codigo="9090", cod_kit=null
        - Itens do kit: cod_kit="9090"
        - Busca: get_by_cod_kit("9090") retorna todos os produtos com cod_kit="9090"
        """
        # Garante que cod_kit seja string (pode vir como int do banco)
        cod_kit_str = str(cod_kit) if cod_kit is not None else None
        query = session.query(Product).filter(Product.cod_kit == cod_kit_str)
        
        if exclude_product_id is not None:
            query = query.filter(Product.id_produto != exclude_product_id)
        
        return query.all()
