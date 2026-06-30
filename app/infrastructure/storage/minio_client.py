"""Cliente MinIO/S3 de baixo nível — camada de infraestrutura.

Responsabilidades:
- Manter singleton do boto3 client por processo Gunicorn
- Criar buckets no startup se não existirem
- Operações brutas: upload, download, delete, list
"""

from typing import Iterator, List, Optional, Tuple
from loguru import logger
import boto3
from botocore.client import Config
from botocore.exceptions import ClientError

import envs


class MinioClient:
    """Singleton do cliente S3 (boto3) apontando para o MinIO interno."""

    _client = None

    # ------------------------------------------------------------------ #
    # Conexão                                                              #
    # ------------------------------------------------------------------ #

    @classmethod
    def get_client(cls):
        if cls._client is None:
            cls._client = boto3.client(
                "s3",
                endpoint_url=envs.MINIO_ENDPOINT,
                aws_access_key_id=envs.MINIO_ACCESS_KEY,
                aws_secret_access_key=envs.MINIO_SECRET_KEY,
                config=Config(signature_version="s3v4"),
                region_name="us-east-1",
            )
            logger.info(f"MinioClient conectado: {envs.MINIO_ENDPOINT}")
        return cls._client

    # ------------------------------------------------------------------ #
    # Buckets                                                              #
    # ------------------------------------------------------------------ #

    @classmethod
    def ensure_buckets(cls, bucket_names: List[str]) -> None:
        """Cria os buckets listados se ainda não existirem."""
        client = cls.get_client()
        for bucket in bucket_names:
            try:
                client.head_bucket(Bucket=bucket)
                logger.info(f"Bucket OK: {bucket}")
            except ClientError as e:
                code = e.response["Error"].get("Code", "")
                if code in ("404", "NoSuchBucket"):
                    client.create_bucket(Bucket=bucket)
                    logger.info(f"Bucket criado: {bucket}")
                else:
                    logger.error(f"Erro ao verificar bucket '{bucket}': {e}")
                    raise

    @classmethod
    def list_buckets(cls) -> List[str]:
        resp = cls.get_client().list_buckets()
        return [b["Name"] for b in resp.get("Buckets", [])]

    # ------------------------------------------------------------------ #
    # Upload                                                               #
    # ------------------------------------------------------------------ #

    @classmethod
    def upload(cls, bucket: str, key: str, data: bytes, content_type: str) -> None:
        cls.get_client().put_object(
            Bucket=bucket,
            Key=key,
            Body=data,
            ContentType=content_type,
        )

    # ------------------------------------------------------------------ #
    # Download                                                             #
    # ------------------------------------------------------------------ #

    @classmethod
    def get_object(cls, bucket: str, key: str) -> Tuple[Optional[bytes], Optional[str]]:
        """Retorna (bytes, content_type) ou (None, None) se não encontrado."""
        try:
            resp = cls.get_client().get_object(Bucket=bucket, Key=key)
            body = resp["Body"].read()
            content_type = resp.get("ContentType", "application/octet-stream")
            return body, content_type
        except ClientError as e:
            code = e.response["Error"].get("Code", "")
            if code in ("NoSuchKey", "404"):
                return None, None
            raise

    # ------------------------------------------------------------------ #
    # Delete                                                               #
    # ------------------------------------------------------------------ #

    @classmethod
    def delete(cls, bucket: str, key: str) -> None:
        cls.get_client().delete_object(Bucket=bucket, Key=key)

    @classmethod
    def delete_many(cls, bucket: str, keys: List[str]) -> None:
        if not keys:
            return
        cls.get_client().delete_objects(
            Bucket=bucket,
            Delete={"Objects": [{"Key": k} for k in keys], "Quiet": True},
        )

    # ------------------------------------------------------------------ #
    # List                                                                 #
    # ------------------------------------------------------------------ #

    @classmethod
    def list_keys(cls, bucket: str, prefix: str = "") -> Iterator[str]:
        """Itera sobre todos os object keys no bucket com o prefixo dado."""
        paginator = cls.get_client().get_paginator("list_objects_v2")
        for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
            for obj in page.get("Contents", []):
                yield obj["Key"]

    # ------------------------------------------------------------------ #
    # Existência                                                           #
    # ------------------------------------------------------------------ #

    @classmethod
    def exists(cls, bucket: str, key: str) -> bool:
        try:
            cls.get_client().head_object(Bucket=bucket, Key=key)
            return True
        except ClientError:
            return False

    # ------------------------------------------------------------------ #
    # Presigned URL (uso interno/temporário)                               #
    # ------------------------------------------------------------------ #

    @classmethod
    def presigned_url(cls, bucket: str, key: str, expires_in: int = 3600) -> Optional[str]:
        try:
            return cls.get_client().generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": key},
                ExpiresIn=expires_in,
            )
        except Exception as e:
            logger.error(f"Erro ao gerar presigned URL bucket={bucket} key={key}: {e}")
            return None
