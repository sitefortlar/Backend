"""Implementação do repository para ProductImage"""

from typing import Optional, List

from app.domain.models.product_image_model import ProductImage
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository


class ProductImageRepositoryImpl(IProductImageRepository):
    """Repository para operações de ProductImage com CRUD completo"""

    # Implementação dos métodos abstratos do IProductImageRepository
    def create(self, product_image: ProductImage, session: Session) -> ProductImage:
        """Cria um novo product_image"""
        session.add(product_image)
        session.flush()
        session.refresh(product_image)
        return product_image

    def get_by_id(self, image_id: int, session: Session) -> Optional[ProductImage]:
        """Busca product_image por ID"""
        return session.query(ProductImage).filter(ProductImage.id_imagem == image_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[ProductImage]:
        """Lista todos os product_images"""
        return session.query(ProductImage).offset(skip).limit(limit).all()

    def update(self, product_image: ProductImage, session: Session) -> ProductImage:
        """Atualiza um product_image"""
        session.merge(product_image)
        session.flush()
        return product_image

    def delete(self, image_id: int, session: Session) -> bool:
        """Deleta um product_image por ID"""
        image = self.get_by_id(image_id, session)
        if image:
            session.delete(image)
            session.flush()
            return True
        return False

    def get_by_produto(self, produto_id: int, session: Session) -> List[ProductImage]:
        """Busca todas as imagens de um produto"""
        return session.query(ProductImage).filter(
            ProductImage.id_produto == produto_id
        ).all()

    def delete_by_produto(self, produto_id: int, session: Session) -> bool:
        """Deleta todas as imagens de um produto"""
        images = self.get_by_produto(produto_id, session)
        if images:
            for image in images:
                session.delete(image)
            session.flush()
            return True
        return False

    def get_by_url(self, url: str, session: Session) -> Optional[ProductImage]:
        """Busca imagem por URL"""
        return session.query(ProductImage).filter(
            ProductImage.url == url
        ).first()

    def exists_by_url(self, url: str, produto_id: int, session: Session) -> bool:
        """Verifica se já existe uma imagem com esta URL para o produto"""
        return session.query(ProductImage).filter(
            ProductImage.url == url,
            ProductImage.id_produto == produto_id
        ).first() is not None

