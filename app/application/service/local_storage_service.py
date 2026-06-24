"""Serviço de armazenamento local para arquivos e imagens"""

import shutil
from pathlib import Path
from typing import Optional
from loguru import logger

import envs


class LocalStorageService:
    """Armazenamento local em disco — substitui o Supabase Storage.

    Interface mantida compatível com SupabaseService para minimizar
    alterações nos use cases que a consomem.
    """

    def __init__(self):
        self.upload_dir = Path(envs.UPLOAD_DIR)
        self.base_url = envs.APP_BASE_URL.rstrip("/")
        self.upload_dir.mkdir(parents=True, exist_ok=True)
        logger.info(f"LocalStorageService inicializado. Diretório: {self.upload_dir}, Base URL: {self.base_url}")

    # ------------------------------------------------------------------
    # Upload
    # ------------------------------------------------------------------

    def upload_image(self, file_name: str, file_bytes: bytes, content_type: str = "image/jpeg") -> Optional[str]:
        """Salva imagem em disco e retorna URL pública."""
        try:
            if "/" not in file_name:
                file_name = f"produtos/{file_name}"
            dest = self.upload_dir / file_name
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(file_bytes)
            url = self.public_url_for_path(file_name)
            logger.info(f"Imagem salva: {dest} → {url}")
            return url
        except Exception as e:
            logger.error(f"Erro ao salvar imagem '{file_name}': {e}")
            return None

    def upload_file(self, file_name: str, file_bytes: bytes, content_type: str = "application/octet-stream") -> Optional[str]:
        """Salva arquivo genérico em disco e retorna URL pública."""
        try:
            if "/" not in file_name:
                file_name = f"planilhas/{file_name}"
            dest = self.upload_dir / file_name
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(file_bytes)
            url = self.public_url_for_path(file_name)
            logger.info(f"Arquivo salvo: {dest} → {url}")
            return url
        except Exception as e:
            logger.error(f"Erro ao salvar arquivo '{file_name}': {e}")
            return None

    # ------------------------------------------------------------------
    # URL helpers
    # ------------------------------------------------------------------

    def public_url_for_path(self, path: str) -> str:
        """Constrói URL pública para um path relativo ao upload_dir.

        Ex: 'produtos/abc.jpg' → 'http://localhost:8000/uploads/produtos/abc.jpg'
        """
        clean = path.lstrip("/")
        return f"{self.base_url}/uploads/{clean}"

    def path_from_public_url(self, public_url: str) -> Optional[str]:
        """Extrai path relativo ao upload_dir a partir da URL pública.

        Ex: 'http://localhost:8000/uploads/produtos/abc.jpg' → 'produtos/abc.jpg'
        """
        if not public_url:
            return None
        marker = "/uploads/"
        idx = public_url.find(marker)
        if idx != -1:
            return public_url[idx + len(marker):]
        return None

    def get_public_url(self, path: str) -> str:
        """Alias de public_url_for_path."""
        return self.public_url_for_path(path)

    # ------------------------------------------------------------------
    # Delete
    # ------------------------------------------------------------------

    def delete_file(self, path: str) -> bool:
        """Remove arquivo do disco."""
        try:
            target = self.upload_dir / path.lstrip("/")
            if target.exists():
                target.unlink()
                logger.info(f"Arquivo removido: {target}")
            return True
        except Exception as e:
            logger.warning(f"Erro ao remover arquivo '{path}': {e}")
            return False

    def delete_all_images_in_folder(self, folder: str = "produtos") -> bool:
        """Remove todos os arquivos de uma pasta e recria a pasta vazia."""
        try:
            target_dir = self.upload_dir / folder.lstrip("/")
            if target_dir.exists():
                shutil.rmtree(target_dir)
                logger.info(f"Pasta removida: {target_dir}")
            target_dir.mkdir(parents=True, exist_ok=True)
            return True
        except Exception as e:
            logger.error(f"Erro ao limpar pasta '{folder}': {e}")
            return False

    # ------------------------------------------------------------------
    # Utilitários
    # ------------------------------------------------------------------

    def file_exists(self, path: str) -> bool:
        """Verifica se arquivo existe no disco."""
        target = self.upload_dir / path.lstrip("/")
        return target.exists()
