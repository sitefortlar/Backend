from typing import Optional, List

from app.domain.models.activity_branch_model import ActivityBranch
from app.infrastructure.configs.database_config import Session
from app.infrastructure.repositories.ramo_atividade_repository_interface import IRamoAtividadeRepository


class RamoAtividadeRepositoryImpl(IRamoAtividadeRepository):
    """Repository para operações de RamoAtividade com CRUD completo"""

    def create(self, ramo_atividade: ActivityBranch, session: Session) -> ActivityBranch:
        """Cria um novo ramo de atividade"""
        session.add(ramo_atividade)
        session.flush()
        return ramo_atividade

    def get_by_id(self, ramo_id: int, session: Session) -> Optional[ActivityBranch]:
        """Busca ramo de atividade por ID"""
        return session.query(ActivityBranch).filter(ActivityBranch.id == ramo_id).first()

    def get_all(self, session: Session, skip: int = 0, limit: int = 100) -> List[ActivityBranch]:
        """Lista todos os ramos de atividade"""
        return session.query(ActivityBranch).offset(skip).limit(limit).all()

    def update(self, ramo_atividade: ActivityBranch, session: Session) -> ActivityBranch:
        """Atualiza um ramo de atividade"""
        session.merge(ramo_atividade)
        session.flush()
        return ramo_atividade

    def delete(self, ramo_id: int, session: Session) -> bool:
        """Deleta um ramo de atividade"""
        ramo = self.get_by_id(ramo_id, session)
        if ramo:
            session.delete(ramo)
            session.flush()
            return True
        return False

    def exists_by_id(self, ramo_id: int, session: Session) -> bool:
        """Verifica se ramo de atividade existe por ID"""
        return session.query(ActivityBranch).filter(ActivityBranch.id == ramo_id).first() is not None

    def search_by_description(self, description: str, session: Session) -> List[ActivityBranch]:
        """Busca ramos de atividade por descrição"""
        return session.query(ActivityBranch).filter(
            ActivityBranch.descricao.ilike(f"%{description}%")
        ).all()

    def get_by_description(self, description: str, session: Session) -> Optional[ActivityBranch]:
        """Busca ramo de atividade por descrição exata"""
        return session.query(ActivityBranch).filter(ActivityBranch.descricao == description).first()
