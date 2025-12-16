"""Serviço para gerenciar jobs assíncronos de processamento"""

import uuid
import threading
from datetime import datetime
from typing import Dict, Optional
from enum import Enum
from loguru import logger


class JobStatus(str, Enum):
    """Status possíveis de um job"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class JobService:
    """Serviço singleton para gerenciar jobs assíncronos"""
    
    _instance = None
    _lock = threading.Lock()
    
    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super(JobService, cls).__new__(cls)
                    cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self._jobs: Dict[str, Dict] = {}
        self._lock = threading.Lock()
        self._initialized = True
        logger.info("JobService inicializado")
    
    def create_job(self) -> str:
        """
        Cria um novo job e retorna seu ID
        
        Returns:
            ID único do job
        """
        job_id = str(uuid.uuid4())
        with self._lock:
            self._jobs[job_id] = {
                "id": job_id,
                "status": JobStatus.PENDING,
                "created_at": datetime.now().isoformat(),
                "started_at": None,
                "completed_at": None,
                "progress": 0,
                "result": None,
                "error": None,
                "summary": None
            }
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
        with self._lock:
            if job_id in self._jobs:
                self._jobs[job_id]["status"] = status
                if status == JobStatus.PROCESSING and not self._jobs[job_id]["started_at"]:
                    self._jobs[job_id]["started_at"] = datetime.now().isoformat()
                elif status in [JobStatus.COMPLETED, JobStatus.FAILED]:
                    self._jobs[job_id]["completed_at"] = datetime.now().isoformat()
                
                # Atualiza campos adicionais
                for key, value in kwargs.items():
                    if key in ["progress", "result", "error", "summary"]:
                        self._jobs[job_id][key] = value
                
                logger.debug(f"Job {job_id} atualizado: {status}")
            else:
                logger.warning(f"Tentativa de atualizar job inexistente: {job_id}")
    
    def get_job(self, job_id: str) -> Optional[Dict]:
        """
        Obtém informações de um job
        
        Args:
            job_id: ID do job
            
        Returns:
            Dicionário com informações do job ou None se não existir
        """
        with self._lock:
            return self._jobs.get(job_id)
    
    def cleanup_old_jobs(self, max_age_hours: int = 24):
        """
        Remove jobs antigos da memória
        
        Args:
            max_age_hours: Idade máxima em horas para manter jobs (padrão: 24h)
        """
        from datetime import datetime, timedelta
        
        cutoff_time = datetime.now() - timedelta(hours=max_age_hours)
        with self._lock:
            jobs_to_remove = [
                job_id for job_id, job_data in self._jobs.items()
                if job_data.get("completed_at") and 
                datetime.fromisoformat(job_data["completed_at"]) < cutoff_time
            ]
            
            for job_id in jobs_to_remove:
                del self._jobs[job_id]
                logger.debug(f"Job antigo removido: {job_id}")
            
            if jobs_to_remove:
                logger.info(f"Limpeza: {len(jobs_to_remove)} job(s) antigo(s) removido(s)")

