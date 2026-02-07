"""Use case para atualizar um produto (dados, texto, preço)"""

from typing import Dict, Any, Optional
from decimal import Decimal
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.domain.models.product_model import Product
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl


class UpdateProductUseCase(UseCase[Dict[str, Any], Product]):
    """Use case para atualizar produto (nome, descrição, preço, categoria, ativo, etc.)"""

    def __init__(self):
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.category_repository: ICategoryRepository = CategoryRepositoryImpl()
        self.subcategory_repository: ISubcategoryRepository = SubcategoryRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Product:
        """Atualiza o produto com os campos enviados (apenas os informados)."""
        try:
            product_id = request.get("product_id")
            if not product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do produto é obrigatório"
                )

            product = self.product_repository.get_by_id(product_id, session)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

            # Atualiza apenas campos presentes no request
            if "nome" in request and request["nome"] is not None:
                product.nome = request["nome"].strip()
            if "descricao" in request:
                product.descricao = request["descricao"] if request["descricao"] is not None else None
            if "quantidade" in request and request["quantidade"] is not None:
                product.quantidade = request["quantidade"]
            if "cod_kit" in request:
                product.cod_kit = request["cod_kit"] if request["cod_kit"] is not None else None
            if "id_categoria" in request and request["id_categoria"] is not None:
                cat = self.category_repository.get_by_id(request["id_categoria"], session)
                if not cat:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Categoria com ID {request['id_categoria']} não encontrada"
                    )
                product.id_categoria = request["id_categoria"]
            if "id_subcategoria" in request and request["id_subcategoria"] is not None:
                sub = self.subcategory_repository.get_by_id(request["id_subcategoria"], session)
                if not sub:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"Subcategoria com ID {request['id_subcategoria']} não encontrada"
                    )
                product.id_subcategoria = request["id_subcategoria"]
            if "valor_base" in request and request["valor_base"] is not None:
                product.valor_base = Decimal(str(request["valor_base"]))
            if "ativo" in request and request["ativo"] is not None:
                product.ativo = request["ativo"]

            updated = self.product_repository.update(product, session)
            logger.info(f"Produto atualizado: id={updated.id_produto}, nome={updated.nome}")
            return updated

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao atualizar produto: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao atualizar produto: {str(e)}"
            )
