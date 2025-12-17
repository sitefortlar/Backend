"""Interface do repository para Product"""

from abc import ABC, abstractmethod
from typing import Optional, List

from app.domain.models.product_model import Product
from app.infrastructure.configs.database_config import Session


class IProductRepository(ABC):
    """Interface para operações de Product"""

    @abstractmethod
    def create(self, product: Product, session: Session) -> Product:
        pass

    @abstractmethod
    def get_by_id(self, product_id: int, session: Session) -> Optional[Product]:
        pass

    @abstractmethod
    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Product]:
        pass

    @abstractmethod
    def update(self, product: Product, session: Session) -> Product:
        pass

    @abstractmethod
    def delete(self, product_id: int, session: Session) -> bool:
        pass

    @abstractmethod
    def get_by_codigo(self, codigo: str, session: Session) -> Optional[Product]:
        pass

    @abstractmethod
    def get_by_categoria(self, categoria_id: int, session: Session) -> List[Product]:
        pass

    @abstractmethod
    def get_by_subcategoria(self, subcategoria_id: int, session: Session) -> List[Product]:
        pass

    @abstractmethod
    def get_active_products(self, session: Session) -> List[Product]:
        pass

    @abstractmethod
    def search_by_name(self, name: str, session: Session, exclude_kits: bool = False) -> List[Product]:
        pass

    @abstractmethod
    def get_by_price_range(self, min_price: float, max_price: float, session: Session) -> List[Product]:
        pass

    @abstractmethod
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
        pass

    @abstractmethod
    def get_by_cod_kit(self, cod_kit: str, exclude_product_id: Optional[int] = None, session: Session = None) -> List[Product]:
        """Busca produtos por cod_kit, opcionalmente excluindo um produto específico"""
        pass

    @abstractmethod
    def get_by_ids(self, product_ids: List[int], session: Session) -> List[Product]:
        """Busca produtos por lista de IDs (em lote)"""
        pass
