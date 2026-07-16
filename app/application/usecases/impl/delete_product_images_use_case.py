"""Use case para remover uma ou mais imagens de um produto (banco + storage)"""

from typing import Dict, Any, List
from fastapi import HTTPException, status
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.application.service.storage_service import StorageService
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.product_image_repository_impl import ProductImageRepositoryImpl


class DeleteProductImagesUseCase(UseCase[Dict[str, Any], Dict[str, List[int]]]):
    """Use case para deletar uma ou mais imagens de um produto (registro e arquivo no storage)."""

    def __init__(self):
        self.storage_service = StorageService()
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.product_image_repository: IProductImageRepository = ProductImageRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, List[int]]:
        """
        request: product_id (int), image_ids (List[int])
        """
        try:
            product_id = request.get("product_id")
            image_ids = request.get("image_ids") or []

            if not product_id or not image_ids:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="product_id e image_ids são obrigatórios"
                )

            product = self.product_repository.get_by_id(product_id, session)
            if not product:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Produto não encontrado"
                )

            removidas: List[int] = []
            nao_encontradas: List[int] = []

            for image_id in image_ids:
                if self._delete_one(product_id, image_id, session):
                    removidas.append(image_id)
                else:
                    nao_encontradas.append(image_id)

            logger.info(
                f"Exclusão de imagens do produto {product_id}: "
                f"removidas={removidas} nao_encontradas={nao_encontradas}"
            )
            return {"removidas": removidas, "nao_encontradas": nao_encontradas}

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Erro ao remover imagens do produto: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao remover imagens: {str(e)}"
            )

    def _delete_one(self, product_id: int, image_id: int, session) -> bool:
        image = self.product_image_repository.get_by_id(image_id, session)
        if not image or image.id_produto != product_id:
            logger.warning(f"Imagem {image_id} não encontrada para o produto {product_id}")
            return False

        url = image.url
        deleted = self.product_image_repository.delete(image_id, session)
        if not deleted:
            logger.warning(f"Falha ao remover registro da imagem {image_id} do banco")
            return False

        path = self.storage_service.path_from_public_url(url)
        if path:
            # delete_file já loga um warning e retorna False sem lançar exceção
            # quando o objeto não existe mais no MinIO — não deve bloquear a exclusão.
            self.storage_service.delete_file(path)

        return True
