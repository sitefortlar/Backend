"""Use case para adicionar uma ou mais imagens a um produto (upload em lote + registro no banco)"""

import uuid
from typing import Dict, Any, List
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.application.service.storage_service import StorageService
from app.domain.models.product_image_model import ProductImage
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.product_image_repository_impl import ProductImageRepositoryImpl
from app.infrastructure.utils.file_utils import get_file_extension_from_content_type


class AddProductImagesUseCase(UseCase[Dict[str, Any], List[ProductImage]]):
    """Use case para adicionar uma ou mais imagens a um produto."""

    def __init__(self):
        self.storage_service = StorageService()
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.product_image_repository: IProductImageRepository = ProductImageRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> List[ProductImage]:
        """
        request: product_id (int), files (List[dict] com file_bytes, file_name, content_type)
        """
        try:
            product_id = request.get("product_id")
            files = request.get("files") or []

            if not product_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="ID do produto é obrigatório"
                )
            if not files:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Nenhum arquivo de imagem enviado"
                )

            product = self.product_repository.get_by_id(product_id, session)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

            created: List[ProductImage] = []
            for file_data in files:
                image = self._upload_one(product_id, file_data, session)
                if image:
                    created.append(image)

            if not created:
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail="Falha ao enviar todas as imagens para o storage"
                )

            logger.info(
                f"Imagens adicionadas ao produto {product_id}: "
                f"{len(created)}/{len(files)} enviadas com sucesso"
            )
            return created

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao adicionar imagens ao produto: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao adicionar imagens: {str(e)}"
            )

    def _upload_one(self, product_id: int, file_data: Dict[str, Any], session) -> ProductImage:
        file_bytes = file_data.get("file_bytes")
        content_type = file_data.get("content_type") or "image/jpeg"

        if not file_bytes:
            logger.warning(f"Arquivo vazio ignorado para o produto {product_id}")
            return None

        ext = get_file_extension_from_content_type(content_type).lstrip(".")
        unique_name = f"{uuid.uuid4().hex}.{ext}"
        storage_path = f"produtos/shared/{unique_name}"

        public_url = self.storage_service.upload_image(storage_path, file_bytes, content_type)
        if not public_url:
            logger.error(f"Falha ao enviar imagem '{unique_name}' ao storage (produto {product_id})")
            return None

        product_image = ProductImage(id_produto=product_id, url=public_url)
        return self.product_image_repository.create(product_image, session)
