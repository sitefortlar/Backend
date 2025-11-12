"""Interface do repository para ProductImage"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.product_image_model import ProductImage
from app.infrastructure.configs.database_config import Session


class IProductImageRepository(ABC):
    """Interface para operações de ProductImage"""

    @abstractmethod
    def create(self, product_image: ProductImage, session: Session) -> ProductImage:
        pass

    @abstractmethod
    def get_by_id(self, image_id: int, session: Session) -> Optional[ProductImage]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[ProductImage]:
        pass

    @abstractmethod
    def update(self, product_image: ProductImage, session: Session) -> ProductImage:
        pass

    @abstractmethod
    def delete(self, image_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_produto(self, produto_id: int, session: Session) -> List[ProductImage]:
        """Busca todas as imagens de um produto"""
        pass

    @abstractmethod
    def delete_by_produto(self, produto_id: int, session: Session) -> bool:
        """Deleta todas as imagens de um produto"""
        pass

    @abstractmethod
    def get_by_url(self, url: str, session: Session) -> Optional[ProductImage]:
        """Busca imagem por URL"""
        pass

    @abstractmethod
    def exists_by_url(self, url: str, produto_id: int, session: Session) -> bool:
        """Verifica se já existe uma imagem com esta URL para o produto"""
        pass

