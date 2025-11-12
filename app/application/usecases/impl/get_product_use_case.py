"""Use case para buscar produto por ID"""

from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from decimal import Decimal

from app.application.usecases.use_case import UseCase
from app.domain.models.product_model import Product
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.region_repository_interface import IRegionRepository
from app.infrastructure.repositories.impl.region_repository_impl import RegionRepositoryImpl


class GetProductUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Use case para buscar produto por ID"""

    def __init__(self):
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.region_repository: IRegionRepository = RegionRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        """Executa o caso de uso de busca de produto por ID"""
        try:
            product_id = request.get('product_id')
            estado = request.get('estado')
            
            if not product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do produto é obrigatório"
                )
            
            if not estado:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Estado é obrigatório"
                )

            # Busca o produto
            product = self.product_repository.get_by_id(product_id, session)

            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

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

            return self._build_product_response(product, region, session)

        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao buscar produto: {str(e)}"
            )

    def _build_product_response(self, product: Product, region, session=None) -> Dict[str, Any]:
        """Constrói a resposta do produto com preços calculados e kits relacionados"""
        # Converte cod_kit para string ou None (pode vir como int do banco)
        cod_kit_str = None
        if product.cod_kit is not None:
            cod_kit_str = str(product.cod_kit)
        
        # Calcula os preços com desconto
        valor_base = Decimal(product.valor_base)
        
        # avista = valor_base * desconto_0
        avista = float(valor_base * region.desconto_0)
        
        # 30_dias = valor_base * desconto_30
        dias_30 = float(valor_base * region.desconto_30)
        
        # 60_dias = valor_base * desconto_60
        dias_60 = float(valor_base * region.desconto_60)
        
        # 🧩 NOVA LÓGICA: Identificar itens de cada kit
        # Para cada produto base, buscar produtos cujo cod_kit seja igual ao código do produto base
        # Esses produtos serão os itens pertencentes ao kit
        kits = []
        if product.codigo and session and product.cod_kit is None:
            # Só busca kits se o produto for base (cod_kit == null)
            # Busca produtos onde cod_kit == product.codigo
            # Garante que codigo seja string (pode vir como int do banco)
            codigo_str = str(product.codigo) if product.codigo is not None else None
            if codigo_str:
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
    
    def _build_kit_product_response(self, product: Product, region) -> Dict[str, Any]:
        """Constrói a resposta de um produto do kit (sem kits aninhados)"""
        # Converte cod_kit para string ou None
        cod_kit_str = None
        if product.cod_kit is not None:
            cod_kit_str = str(product.cod_kit)
        
        # Calcula os preços com desconto
        valor_base = Decimal(product.valor_base)
        
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

