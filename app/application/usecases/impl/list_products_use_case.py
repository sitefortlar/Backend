"""Use case para listar produtos"""

from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status
from decimal import Decimal
from collections import defaultdict

from app.application.usecases.use_case import UseCase
from app.domain.models.product_model import Product
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.region_repository_interface import IRegionRepository
from app.infrastructure.repositories.impl.region_repository_impl import RegionRepositoryImpl


class ListProductsUseCase(UseCase[Dict[str, Any], List[Dict[str, Any]]]):
    """Use case para listar produtos"""

    def __init__(self):
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.region_repository: IRegionRepository = RegionRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> List[Dict[str, Any]]:
        """Executa o caso de uso de listagem de produtos com filtros consolidados"""
        try:
            estado = request.get('estado')
            
            if not estado:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Estado é obrigatório"
                )
            
            skip = request.get('skip', 0)
            limit = request.get('limit')  # None se não for passado (retorna todos)
            active_only = request.get('active_only', True)
            categoria_id = request.get('id_category') or request.get('categoria_id')
            subcategoria_id = request.get('id_subcategory') or request.get('subcategoria_id')
            order_price = request.get('order_price')  # 'ASC' ou 'DESC'
            # Por padrão, manter compatibilidade: incluir kits
            include_kits = bool(request.get('include_kits', True))
            search_name = request.get('search_name')
            min_price = request.get('min_price')
            max_price = request.get('max_price')

            # Busca a região para aplicar descontos
            # Se for MG ou ES, usa os descontos desses estados, senão usa SP
            estado_para_busca = estado.upper()
            if estado_para_busca not in ['MG', 'ES']:
                estado_para_busca = 'SP'
            
            region = self.region_repository.get_by_estado(estado_para_busca, session)
            
            if not region:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Região '{estado_para_busca}' não encontrada na base de dados"
                )

            # 🧩 NOVA LÓGICA: Buscar produtos base (sem kit) - onde cod_kit == null
            # Esses produtos representam os kits principais
            if search_name:
                products = self.product_repository.search_by_name(search_name, session, exclude_kits=True)
            elif min_price is not None and max_price is not None:
                # Para busca por faixa de preço, também precisa excluir kits
                all_products = self.product_repository.get_by_price_range(
                    Decimal(str(min_price)), 
                    Decimal(str(max_price)), 
                    session
                )
                # Filtra produtos: mantém os que não têm cod_kit OU os que têm cod_kit mas não têm produto pai
                products = []
                for p in all_products:
                    if p.cod_kit is None:
                        products.append(p)
                    else:
                        # Verifica se existe produto pai com codigo igual ao cod_kit
                        # Converte cod_kit para string (pode vir como int do banco)
                        cod_kit_str = str(p.cod_kit) if p.cod_kit is not None else None
                        if cod_kit_str:
                            parent = self.product_repository.get_by_codigo(cod_kit_str, session)
                            if not parent:
                                # Não tem pai, então aparece na listagem
                                products.append(p)
                        else:
                            # Se cod_kit for None, aparece na listagem
                            products.append(p)
            else:
                # Usa método consolidado que suporta todos os filtros
                # Retorna apenas produtos base (cod_kit == null) ou produtos sem pai
                products = self.product_repository.get_all_with_filters(
                    session=session,
                    categoria_id=categoria_id,
                    subcategoria_id=subcategoria_id,
                    active_only=active_only,
                    order_by_price=order_price,
                    skip=skip,
                    limit=limit,
                    exclude_kits=True
                )

            # Otimização: se include_kits, buscar todos os itens de kit em UMA query e agrupar por cod_kit
            kit_map = None
            if include_kits and session:
                kit_map = self._build_kit_map(products, session)

            # Converte para DTOs de resposta
            return [
                self._build_product_response(product, region, session, include_kits=include_kits, kit_map=kit_map)
                for product in products
            ]

        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao listar produtos: {str(e)}"
            )

    def _build_product_response(self, product: Product, region, session=None, include_kits: bool = True, kit_map: Optional[Dict[str, List[Product]]] = None) -> Dict[str, Any]:
        """Constrói a resposta do product com preços calculados e kits relacionados"""
        # Converte cod_kit para string ou None (pode vir como int do banco)
        cod_kit_str = None
        if product.cod_kit is not None:
            cod_kit_str = str(product.cod_kit)
        
        # Calcula os preços com desconto
        valor_base = Decimal(str(product.valor_base))
        
        # avista = valor_base * desconto_0
        avista = float(valor_base * region.desconto_0)
        
        # 30_dias = valor_base * desconto_30
        dias_30 = float(valor_base * region.desconto_30)
        
        # 60_dias = valor_base * desconto_60
        dias_60 = float(valor_base * region.desconto_60)
        
        # 🧩 NOVA LÓGICA: Identificar itens de cada kit
        # Para cada produto base retornado, obter o valor de seu código (codigo)
        # Em seguida, buscar produtos cujo cod_kit seja igual a esse código
        # Esses produtos serão os itens pertencentes ao kit
        kits = []
        if include_kits and product.codigo and session and product.cod_kit is None:
            # Só busca kits se o produto for base (cod_kit == null)
            # Busca produtos onde cod_kit == product.codigo
            # Garante que codigo seja string (pode vir como int do banco)
            codigo_str = str(product.codigo) if product.codigo is not None else None
            if codigo_str:
                if kit_map is not None:
                    kit_products = kit_map.get(codigo_str, [])
                else:
                    kit_products = self.product_repository.get_by_cod_kit(codigo_str, exclude_product_id=product.id_produto, session=session)
                kits = [self._build_kit_product_response(kit_product, region) for kit_product in kit_products]
        
        return {
            'id_produto': product.id_produto,
            'codigo': product.codigo,
            'nome': product.nome,
            'descricao': product.descricao,
            'quantidade': product.quantidade,
            'cod_kit': cod_kit_str,
            'id_categoria': product.id_categoria,
            'id_subcategoria': product.id_subcategoria,
            'valor_base': float(product.valor_base),
            'ativo': product.ativo,
            'created_at': product.created_at.isoformat(),
            'updated_at': product.updated_at.isoformat() if product.updated_at else None,
            'categoria': product.categoria.nome if product.categoria else None,
            'subcategoria': product.subcategoria.nome if product.subcategoria else None,
            'imagens': [img.url for img in product.imagens] if product.imagens else [],
            'avista': round(avista, 2),
            '30_dias': round(dias_30, 2),
            '60_dias': round(dias_60, 2),
            'kits': kits
        }

    def _build_kit_map(self, products: List[Product], session) -> Dict[str, List[Product]]:
        """
        Monta um dicionário {cod_kit -> [produtos do kit]} em uma única query.
        Evita N+1 quando include_kits=True.
        """
        from sqlalchemy.orm import selectinload

        base_codigos: List[str] = []
        for p in products:
            if p.cod_kit is None and p.codigo is not None:
                base_codigos.append(str(p.codigo))

        if not base_codigos:
            return {}

        kit_items = (
            session.query(Product)
            .options(
                selectinload(Product.categoria),
                selectinload(Product.subcategoria),
                selectinload(Product.imagens),
            )
            .filter(Product.cod_kit.in_(base_codigos))
            .all()
        )

        kit_map: Dict[str, List[Product]] = defaultdict(list)
        for item in kit_items:
            if item.cod_kit is not None:
                kit_map[str(item.cod_kit)].append(item)

        return dict(kit_map)
    
    def _build_kit_product_response(self, product: Product, region) -> Dict[str, Any]:
        """Constrói a resposta de um produto do kit (sem kits aninhados)"""
        # Converte cod_kit para string ou None
        cod_kit_str = None
        if product.cod_kit is not None:
            cod_kit_str = str(product.cod_kit)
        
        # Calcula os preços com desconto
        valor_base = Decimal(str(product.valor_base))
        
        # avista = valor_base * desconto_0
        avista = float(valor_base * region.desconto_0)
        
        # 30_dias = valor_base * desconto_30
        dias_30 = float(valor_base * region.desconto_30)
        
        # 60_dias = valor_base * desconto_60
        dias_60 = float(valor_base * region.desconto_60)
        
        return {
            'id_produto': product.id_produto,
            'codigo': product.codigo,
            'nome': product.nome,
            'descricao': product.descricao,
            'quantidade': product.quantidade,
            'cod_kit': cod_kit_str,
            'id_categoria': product.id_categoria,
            'id_subcategoria': product.id_subcategoria,
            'valor_base': float(product.valor_base),
            'ativo': product.ativo,
            'created_at': product.created_at.isoformat(),
            'updated_at': product.updated_at.isoformat() if product.updated_at else None,
            'categoria': product.categoria.nome if product.categoria else None,
            'subcategoria': product.subcategoria.nome if product.subcategoria else None,
            'imagens': [img.url for img in product.imagens] if product.imagens else [],
            'avista': round(avista, 2),
            '30_dias': round(dias_30, 2),
            '60_dias': round(dias_60, 2),
            'kits': []  # Produtos dentro de kits não têm kits aninhados
        }
