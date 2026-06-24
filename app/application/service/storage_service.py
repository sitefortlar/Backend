"""Serviço de armazenamento MinIO (S3-compatível) — substitui LocalStorageService"""

from typing import Optional, Tuple
from loguru import logger
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

import envs


class StorageService:
    """Armazenamento de arquivos via MinIO (S3-compatível).

    Interface mantida compatível com LocalStorageService para minimizar
    alterações nos use cases existentes.

    URLs retornadas apontam para o endpoint /api/media/{path} da própria API,
    que atua como proxy — o MinIO nunca fica exposto diretamente ao frontend.
    """

    _client = None  # singleton por processo (Gunicorn cria um por worker)

    def __init__(self):
        self.bucket = envs.MINIO_BUCKET
        self.base_url = envs.APP_BASE_URL.rstrip("/")
        self._ensure_client()

    # ------------------------------------------------------------------
    # Inicialização
    # ------------------------------------------------------------------

    @classmethod
    def _ensure_client(cls) -> None:
        if cls._client is None:
            cls._client = boto3.client(
                "s3",
                endpoint_url=envs.MINIO_ENDPOINT,
                aws_access_key_id=envs.MINIO_ROOT_USER,
                aws_secret_access_key=envs.MINIO_ROOT_PASSWORD,
                config=Config(signature_version="s3v4"),
                region_name="us-east-1",
            )
            logger.info(f"MinIO client criado: endpoint={envs.MINIO_ENDPOINT} bucket={envs.MINIO_BUCKET}")

    @classmethod
    def init_buckets(cls) -> None:
        """Cria buckets necessários se não existirem. Deve ser chamado no startup."""
        cls._ensure_client()
        for bucket_name in {envs.MINIO_BUCKET}:
            try:
                cls._client.head_bucket(Bucket=bucket_name)
                logger.info(f"Bucket MinIO verificado: {bucket_name}")
            except ClientError:
                cls._client.create_bucket(Bucket=bucket_name)
                logger.info(f"Bucket MinIO criado: {bucket_name}")

    # ------------------------------------------------------------------
    # Upload
    # ------------------------------------------------------------------

    def upload_image(self, file_name: str, file_bytes: bytes, content_type: str = "image/jpeg") -> Optional[str]:
        """Faz upload de imagem para MinIO e retorna URL pública via proxy da API."""
        if "/" not in file_name:
            file_name = f"produtos/{file_name}"
        return self._upload(file_name, file_bytes, content_type)

    def upload_file(self, file_name: str, file_bytes: bytes, content_type: str = "application/octet-stream") -> Optional[str]:
        """Faz upload de arquivo (planilha, etc.) para MinIO e retorna URL pública via proxy da API."""
        if "/" not in file_name:
            file_name = f"planilhas/{file_name}"
        return self._upload(file_name, file_bytes, content_type)

    def _upload(self, object_key: str, file_bytes: bytes, content_type: str) -> Optional[str]:
        try:
            self._client.put_object(
                Bucket=self.bucket,
                Key=object_key,
                Body=file_bytes,
                ContentType=content_type,
            )
            url = self.public_url_for_path(object_key)
            logger.info(f"Upload MinIO concluído: key={object_key} size={len(file_bytes)} → {url}")
            return url
        except Exception as e:
            logger.error(f"Erro no upload MinIO key={object_key}: {e}")
            return None

    # ------------------------------------------------------------------
    # URL helpers
    # ------------------------------------------------------------------

    def public_url_for_path(self, path: str) -> str:
        """Constrói URL pública (via proxy da API) para um objeto no MinIO.

        Ex: 'produtos/abc.jpg' → 'https://api.fortlar.com.br/api/media/produtos/abc.jpg'
        """
        clean = path.lstrip("/")
        return f"{self.base_url}/api/media/{clean}"

    def path_from_public_url(self, public_url: str) -> Optional[str]:
        """Extrai object key a partir da URL pública do proxy.

        Suporta tanto o novo padrão (/api/media/) quanto o legado (/uploads/).
        """
        if not public_url:
            return None
        for marker in ("/api/media/", "/uploads/"):
            idx = public_url.find(marker)
            if idx != -1:
                return public_url[idx + len(marker):]
        return None

    def get_public_url(self, path: str) -> str:
        """Alias de public_url_for_path."""
        return self.public_url_for_path(path)

    def get_presigned_url(self, object_key: str, expires_in: int = 3600) -> Optional[str]:
        """Gera presigned URL para acesso interno/temporário (não usar diretamente no frontend)."""
        try:
            return self._client.generate_presigned_url(
                "get_object",
                Params={"Bucket": self.bucket, "Key": object_key},
                ExpiresIn=expires_in,
            )
        except Exception as e:
            logger.error(f"Erro ao gerar presigned URL key={object_key}: {e}")
            return None

    def get_object(self, object_key: str) -> Tuple[Optional[bytes], Optional[str]]:
        """Retorna (bytes, content_type) do objeto, ou (None, None) se não encontrado."""
        try:
            resp = self._client.get_object(Bucket=self.bucket, Key=object_key)
            body = resp["Body"].read()
            content_type = resp.get("ContentType", "application/octet-stream")
            return body, content_type
        except ClientError as e:
            code = e.response["Error"]["Code"]
            if code in ("NoSuchKey", "404"):
                return None, None
            logger.error(f"Erro ao buscar objeto MinIO key={object_key}: {e}")
            raise

    # ------------------------------------------------------------------
    # Delete
    # ------------------------------------------------------------------

    def delete_file(self, path: str) -> bool:
        """Remove objeto do MinIO."""
        try:
            key = path.lstrip("/")
            self._client.delete_object(Bucket=self.bucket, Key=key)
            logger.info(f"Objeto removido do MinIO: {key}")
            return True
        except Exception as e:
            logger.warning(f"Erro ao remover objeto MinIO '{path}': {e}")
            return False

    def delete_all_images_in_folder(self, folder: str = "produtos") -> bool:
        """Remove todos os objetos com o prefixo dado (equivalente a deletar pasta)."""
        try:
            prefix = folder.lstrip("/").rstrip("/") + "/"
            paginator = self._client.get_paginator("list_objects_v2")
            to_delete = []
            for page in paginator.paginate(Bucket=self.bucket, Prefix=prefix):
                for obj in page.get("Contents", []):
                    to_delete.append({"Key": obj["Key"]})

            if to_delete:
                self._client.delete_objects(
                    Bucket=self.bucket,
                    Delete={"Objects": to_delete, "Quiet": True},
                )
                logger.info(f"Removidos {len(to_delete)} objetos do MinIO com prefixo '{prefix}'")
            return True
        except Exception as e:
            logger.error(f"Erro ao limpar prefixo MinIO '{folder}': {e}")
            return False

    # ------------------------------------------------------------------
    # Utilitários
    # ------------------------------------------------------------------

    def file_exists(self, path: str) -> bool:
        """Verifica se objeto existe no MinIO."""
        try:
            self._client.head_object(Bucket=self.bucket, Key=path.lstrip("/"))
            return True
        except ClientError:
            return False
