"""Serviço para gerenciar jobs assíncronos de processamento"""

import uuid
from datetime import datetime, timedelta
from typing import Dict, Optional
from enum import Enum
from loguru import logger

from app.domain.models.job_model import ProcessingJob
from app.infrastructure.configs.database_config import Session


class JobStatus(str, Enum):
    """Status possíveis de um job"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class JobService:
    """Gerencia jobs no banco para que sejam visíveis a todos os workers."""
    
    def create_job(self) -> str:
        """
        Cria um novo job e retorna seu ID
        
        Returns:
            ID único do job
        """
        job_id = str(uuid.uuid4())
        with Session() as session:
            session.add(ProcessingJob(id=job_id, status=JobStatus.PENDING.value))
            session.commit()
        logger.info(f"Job criado: {job_id}")
        return job_id
    
    def update_job_status(self, job_id: str, status: JobStatus, **kwargs):
        """
        Atualiza o status de um job
        
        Args:
            job_id: ID do job
            status: Novo status
            **kwargs: Campos adicionais para atualizar (progress, result, error, summary)
        """
        with Session() as session:
            job = session.get(ProcessingJob, job_id)
            if not job:
                logger.warning(f"Tentativa de atualizar job inexistente: {job_id}")
                return

            job.status = status.value
            if status == JobStatus.PROCESSING and job.started_at is None:
                job.started_at = datetime.now()
            elif status in [JobStatus.COMPLETED, JobStatus.FAILED]:
                job.completed_at = datetime.now()

            for key, value in kwargs.items():
                if key in ["progress", "result", "error", "summary"]:
                    setattr(job, key, value)
            session.commit()
            logger.debug(f"Job {job_id} atualizado: {status}")
    
    def get_job(self, job_id: str) -> Optional[Dict]:
        """
        Obtém informações de um job
        
        Args:
            job_id: ID do job
            
        Returns:
            Dicionário com informações do job ou None se não existir
        """
        with Session() as session:
            job = session.get(ProcessingJob, job_id)
            if not job:
                return None
            return {
                "id": job.id,
                "status": job.status,
                "created_at": job.created_at.isoformat() if job.created_at else None,
                "started_at": job.started_at.isoformat() if job.started_at else None,
                "completed_at": job.completed_at.isoformat() if job.completed_at else None,
                "progress": job.progress,
                "result": job.result,
                "error": job.error,
                "summary": job.summary,
            }
    
    def cleanup_old_jobs(self, max_age_hours: int = 24):
        """
        Remove jobs antigos da memória
        
        Args:
            max_age_hours: Idade máxima em horas para manter jobs (padrão: 24h)
        """
        cutoff_time = datetime.now() - timedelta(hours=max_age_hours)
        with Session() as session:
            jobs_to_remove = session.query(ProcessingJob).filter(
                ProcessingJob.completed_at.is_not(None),
                ProcessingJob.completed_at < cutoff_time,
            ).delete(synchronize_session=False)
            session.commit()
            if jobs_to_remove:
                logger.info(f"Limpeza: {jobs_to_remove} job(s) antigo(s) removido(s)")

