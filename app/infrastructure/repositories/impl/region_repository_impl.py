"""Implementação do repository para Region"""

from typing import Optional, List

from app.domain.models.regions_model import Regions
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.region_repository_interface import IRegionRepository


class RegionRepositoryImpl(IRegionRepository):
    """Repository para operações de Region com CRUD completo"""

    def create(self, region: Regions, session: Session) -> Regions:
        """Cria uma nova region"""
        session.add(region)
        session.flush()
        return region

    def get_by_id(self, region_id: int, session: Session) -> Optional[Regions]:
        """Busca region por ID"""
        return session.query(Regions).filter(Regions.id == region_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Regions]:
        """Lista todas as regions"""
        return session.query(Regions).offset(skip).limit(limit).all()

    def update(self, region: Regions, session: Session) -> Regions:
        """Atualiza uma region"""
        session.merge(region)
        session.flush()
        return region

    def delete(self, region_id: int, session: Session) -> bool:
        """Deleta uma region"""
        region = self.get_by_id(region_id, session)
        if region:
            session.delete(region)
            session.flush()
            return True
        return False

    def get_by_estado(self, estado: str, session: Session) -> Optional[Regions]:
        """Busca region por estado"""
        return session.query(Regions).filter(Regions.estado == estado).first()

    def exists_by_estado(self, estado: str, session: Session) -> bool:
        """Verifica se region existe por estado"""
        return session.query(Regions).filter(Regions.estado == estado).first() is not None

