"""Use case para adicionar imagem a um produto (upload Supabase + registro no banco)"""

import uuid
from typing import Dict, Any
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.application.service.supabase_service import SupabaseService
from app.domain.models.product_image_model import ProductImage
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.product_image_repository_impl import ProductImageRepositoryImpl


# Mapeamento de extensão / content-type comum para imagens
CONTENT_TYPES = {
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "gif": "image/gif",
    "webp": "image/webp",
}


class AddProductImageUseCase(UseCase[Dict[str, Any], ProductImage]):
    """Use case para adicionar uma imagem a um produto."""

    def __init__(self):
        self.supabase_service = SupabaseService()
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.product_image_repository: IProductImageRepository = ProductImageRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> ProductImage:
        """
        request: product_id (int), file_bytes (bytes), file_name (str opcional), content_type (str opcional)
        """
        try:
            product_id = request.get("product_id")
            file_bytes = request.get("file_bytes")
            file_name = request.get("file_name") or "image.jpg"
            content_type = request.get("content_type")

            if not product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do produto é obrigatório"
                )
            if not file_bytes or len(file_bytes) == 0:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Arquivo de imagem é obrigatório"
                )

            product = self.product_repository.get_by_id(product_id, session)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

            # Define content_type por extensão se não informado
            if not content_type:
                ext = (file_name.split(".")[-1] or "jpg").lower()
                content_type = CONTENT_TYPES.get(ext, "image/jpeg")

            # Nome único no storage: produtos/{id_produto}/{uuid}.ext
            ext = (file_name.split(".")[-1] or "jpg").lower()
            if ext not in CONTENT_TYPES:
                ext = "jpg"
            unique_name = f"{uuid.uuid4().hex}.{ext}"
            storage_path = f"produtos/{product_id}/{unique_name}"

            public_url = self.supabase_service.upload_image(
                storage_path, file_bytes, content_type
            )
            if not public_url:
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Falha ao fazer upload da imagem no storage"
                )

            product_image = ProductImage(id_produto=product_id, url=public_url)
            created = self.product_image_repository.create(product_image, session)
            logger.info(f"Imagem adicionada ao produto {product_id}: id_imagem={created.id_imagem}")
            return created

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao adicionar imagem ao produto: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao adicionar imagem: {str(e)}"
            )
