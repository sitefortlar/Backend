"""Use case para remover uma imagem de um produto (banco + Supabase opcional)"""

from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.application.service.supabase_service import SupabaseService
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.product_image_repository_impl import ProductImageRepositoryImpl


class DeleteProductImageUseCase(UseCase[Dict[str, Any], bool]):
    """Use case para deletar uma imagem de um produto (registro e arquivo no Storage)."""

    def __init__(self):
        self.supabase_service = SupabaseService()
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.product_image_repository: IProductImageRepository = ProductImageRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> bool:
        """
        request: product_id (int), image_id (int), delete_from_storage (bool, default True)
        """
        try:
            product_id = request.get("product_id")
            image_id = request.get("image_id")
            delete_from_storage = request.get("delete_from_storage", True)

            if not product_id or not image_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_id e image_id são obrigatórios"
                )

            product = self.product_repository.get_by_id(product_id, session)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

            image = self.product_image_repository.get_by_id(image_id, session)
            if not image:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Imagem não encontrada"
                )
            if image.id_produto != product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Imagem não pertence a este produto"
                )

            url = image.url
            deleted = self.product_image_repository.delete(image_id, session)
            if not deleted:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Falha ao remover imagem do banco"
                )

            if delete_from_storage and url:
                path = self.supabase_service.path_from_public_url(url)
                if path:
                    self.supabase_service.delete_file(path)

            logger.info(f"Imagem removida: product_id={product_id}, image_id={image_id}")
            return True

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao remover imagem do produto: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao remover imagem: {str(e)}"
            )
