"""Serviço de armazenamento — fachada de aplicação sobre MinioClient.

Regras de negócio de storage:
- Imagens de produto  → bucket MINIO_BUCKET_PRODUTOS
- Planilhas / Excel   → bucket MINIO_BUCKET_PLANILHAS
- URLs públicas são servidas por um domínio/proxy externo em frente ao MinIO
  (STORAGE_PUBLIC_BASE_URL) — o backend não serve mais os arquivos.

Estrutura de URL:
  upload_image("produtos/shared/abc.jpg") → bucket=produtos  key=shared/abc.jpg
                                             URL={STORAGE_PUBLIC_BASE_URL}/produtos/shared/abc.jpg

  upload_file("planilhas/file.xlsx")      → bucket=planilhas key=file.xlsx
                                             URL={STORAGE_PUBLIC_BASE_URL}/planilhas/file.xlsx
"""

from typing import Optional, Tuple
from loguru import logger

import envs
from app.infrastructure.storage.minio_client import MinioClient


class StorageService:
    """Fachada de aplicação para operações de storage.

    Use cases consomem esta classe; MinioClient cuida da comunicação S3.
    """

    def __init__(self):
        self.storage_public_base_url = envs.STORAGE_PUBLIC_BASE_URL.rstrip("/")
        self.bucket_produtos = envs.MINIO_BUCKET_PRODUTOS
        self.bucket_planilhas = envs.MINIO_BUCKET_PLANILHAS

    # ------------------------------------------------------------------ #
    # Inicialização (chamada no startup da aplicação)                     #
    # ------------------------------------------------------------------ #

    @classmethod
    def init_buckets(cls) -> None:
        """Cria os buckets necessários se não existirem. Chamado no lifespan."""
        MinioClient.ensure_buckets([
            envs.MINIO_BUCKET_PRODUTOS,
            envs.MINIO_BUCKET_PLANILHAS,
        ])

    # ------------------------------------------------------------------ #
    # Upload                                                               #
    # ------------------------------------------------------------------ #

    def upload_image(self, file_name: str, file_bytes: bytes, content_type: str = "image/jpeg") -> Optional[str]:
        """Upload de imagem para o bucket de produtos."""
        key = self._normalize_key(file_name, strip_prefix="produtos")
        return self._upload(self.bucket_produtos, key, file_bytes, content_type)

    def upload_file(self, file_name: str, file_bytes: bytes, content_type: str = "application/octet-stream") -> Optional[str]:
        """Upload de arquivo (planilha, etc.) para o bucket de planilhas."""
        key = self._normalize_key(file_name, strip_prefix="planilhas")
        return self._upload(self.bucket_planilhas, key, file_bytes, content_type)

    def _upload(self, bucket: str, key: str, file_bytes: bytes, content_type: str) -> Optional[str]:
        try:
            MinioClient.upload(bucket, key, file_bytes, content_type)
            url = self._public_url(bucket, key)
            logger.info(f"Upload OK: bucket={bucket} key={key} size={len(file_bytes)} → {url}")
            return url
        except Exception as e:
            logger.error(f"Erro no upload MinIO bucket={bucket} key={key}: {e}")
            return None

    # ------------------------------------------------------------------ #
    # Delete                                                               #
    # ------------------------------------------------------------------ #

    def delete_file(self, path: str) -> bool:
        """Remove objeto do MinIO. path pode ser a URL pública ou o path relativo."""
        try:
            bucket, key = self._split_path(path)
            MinioClient.delete(bucket, key)
            logger.info(f"Objeto removido: bucket={bucket} key={key}")
            return True
        except Exception as e:
            logger.warning(f"Erro ao remover objeto '{path}': {e}")
            return False

    def delete_all_images_in_folder(self, folder: str = "") -> bool:
        """Remove todos os objetos com o prefixo dado no bucket de produtos."""
        try:
            prefix = folder.strip("/") + "/" if folder.strip("/") else ""
            keys = list(MinioClient.list_keys(self.bucket_produtos, prefix=prefix))
            if keys:
                MinioClient.delete_many(self.bucket_produtos, keys)
                logger.info(f"Removidos {len(keys)} objetos do bucket '{self.bucket_produtos}' prefixo='{prefix}'")
            return True
        except Exception as e:
            logger.error(f"Erro ao limpar prefixo '{folder}' no bucket produtos: {e}")
            return False

    # ------------------------------------------------------------------ #
    # URL helpers                                                          #
    # ------------------------------------------------------------------ #

    def public_url_for_path(self, path: str) -> str:
        """Constrói URL pública a partir de um path 'bucket/key'."""
        clean = path.lstrip("/")
        return f"{self.storage_public_base_url}/{clean}"

    def path_from_public_url(self, public_url: str) -> Optional[str]:
        """Extrai 'bucket/key' a partir da URL pública.

        Suporta o padrão atual (/storage/) e padrões legados (/api/media/, /uploads/)
        para que imagens antigas ainda possam ser resolvidas corretamente.
        """
        if not public_url:
            return None
        for marker in ("/storage/", "/api/media/", "/uploads/"):
            idx = public_url.find(marker)
            if idx != -1:
                return public_url[idx + len(marker):]
        return None

    def get_public_url(self, path: str) -> str:
        return self.public_url_for_path(path)

    def get_presigned_url(self, path: str, expires_in: int = 3600) -> Optional[str]:
        bucket, key = self._split_path(path)
        return MinioClient.presigned_url(bucket, key, expires_in)

    # ------------------------------------------------------------------ #
    # Utilitários                                                          #
    # ------------------------------------------------------------------ #

    def file_exists(self, path: str) -> bool:
        bucket, key = self._split_path(path)
        return MinioClient.exists(bucket, key)

    # ------------------------------------------------------------------ #
    # Internos                                                             #
    # ------------------------------------------------------------------ #

    def _public_url(self, bucket: str, key: str) -> str:
        return f"{self.storage_public_base_url}/{bucket}/{key}"

    def _normalize_key(self, file_name: str, strip_prefix: str) -> str:
        """Remove o prefixo redundante do bucket do key, se presente.

        Ex: "produtos/123/abc.jpg" com strip_prefix="produtos" → "123/abc.jpg"
            "abc.jpg" sem barra → mantém "abc.jpg"
        """
        key = file_name.lstrip("/")
        prefix = strip_prefix.rstrip("/") + "/"
        if key.startswith(prefix):
            key = key[len(prefix):]
        return key

    def _split_path(self, path: str) -> Tuple[str, str]:
        """Divide 'bucket/key/sub' em (bucket, 'key/sub').

        Usado para rotear requisições de media e delete pelo bucket correto.
        Fallback para bucket de produtos quando não há separador.
        """
        clean = path.lstrip("/")
        parts = clean.split("/", 1)
        if len(parts) == 2:
            bucket, key = parts
            # Valida se o bucket é conhecido; caso contrário trata como key no bucket de produtos
            known = {self.bucket_produtos, self.bucket_planilhas}
            if bucket in known:
                return bucket, key
        # path sem bucket explícito — assume produtos (compatibilidade com URLs legadas /uploads/)
        return self.bucket_produtos, clean
