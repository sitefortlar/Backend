"""Implementação do repository para Coupon"""

from typing import Optional, List

from app.domain.models.coupon_model import Coupon
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.coupon_repository_interface import ICouponRepository


class CouponRepositoryImpl(ICouponRepository):
    """Repository para operações de Coupon com CRUD completo"""

    def create(self, coupon: Coupon, session: Session) -> Coupon:
        """Cria um novo cupom"""
        session.add(coupon)
        session.flush()
        return coupon

    def get_by_id(self, coupon_id: int, session: Session) -> Optional[Coupon]:
        """Busca cupom por ID"""
        return session.query(Coupon).filter(Coupon.id_cupom == coupon_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[Coupon]:
        """Lista todos os cupons"""
        return session.query(Coupon).offset(skip).limit(limit).all()

    def update(self, coupon: Coupon, session: Session) -> Coupon:
        """Atualiza um cupom"""
        session.merge(coupon)
        session.flush()
        return coupon

    def delete(self, coupon_id: int, session: Session) -> bool:
        """Deleta um cupom"""
        coupon = self.get_by_id(coupon_id, session)
        if coupon:
            session.delete(coupon)
            session.flush()
            return True
        return False

    def get_by_codigo(self, codigo: str, session: Session) -> Optional[Coupon]:
        """Busca cupom por código"""
        return session.query(Coupon).filter(Coupon.codigo == codigo).first()

    def exists_by_codigo(self, codigo: str, session: Session) -> bool:
        """Verifica se cupom existe por código"""
        return session.query(Coupon).filter(Coupon.codigo == codigo).first() is not None

    def get_active_coupons(self, session: Session, skip: int = 0, limit: int = 100) -> List[Coupon]:
        """Lista cupons ativos"""
        return session.query(Coupon).filter(Coupon.ativo == True).offset(skip).limit(limit).all()
