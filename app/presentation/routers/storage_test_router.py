"""Endpoint temporário para verificar integração com MinIO.

Use para validar a conexão após deploy. Remova ou proteja com autenticação
em produção caso não queira expor o diagnóstico publicamente.
"""

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from loguru import logger

import envs
from app.infrastructure.storage.minio_client import MinioClient

storage_test_router = APIRouter(prefix="/storage", tags=["Storage Diagnóstico"])


@storage_test_router.get("/test", summary="Diagnóstico de conexão com MinIO")
def storage_test():
    """
    Verifica:
    - Conexão com MinIO
    - Buckets existentes
    - Upload de objeto de teste
    - Leitura do objeto enviado
    - Remoção do objeto

    Retorna status detalhado de cada etapa.
    """
    results = {}
    TEST_BUCKET = envs.MINIO_BUCKET_PRODUTOS
    TEST_KEY = "__healthcheck__/test.txt"
    TEST_DATA = b"fortlar-minio-ok"

    # 1. Conexão + listar buckets
    try:
        buckets = MinioClient.list_buckets()
        results["conexao"] = "ok"
        results["buckets"] = buckets
    except Exception as e:
        logger.error(f"[storage_test] Falha na conexão: {e}")
        return JSONResponse(
            {"status": "erro", "etapa": "conexao", "detalhe": str(e)},
            status_code=503,
        )

    # 2. Upload
    try:
        MinioClient.upload(TEST_BUCKET, TEST_KEY, TEST_DATA, "text/plain")
        results["upload"] = "ok"
    except Exception as e:
        logger.error(f"[storage_test] Falha no upload: {e}")
        results["upload"] = f"erro: {e}"

    # 3. Download e verificação de conteúdo
    try:
        body, content_type = MinioClient.get_object(TEST_BUCKET, TEST_KEY)
        results["download"] = "ok" if body == TEST_DATA else f"conteúdo inesperado: {body}"
    except Exception as e:
        logger.error(f"[storage_test] Falha no download: {e}")
        results["download"] = f"erro: {e}"

    # 4. Delete
    try:
        MinioClient.delete(TEST_BUCKET, TEST_KEY)
        results["delete"] = "ok"
    except Exception as e:
        logger.warning(f"[storage_test] Falha no delete: {e}")
        results["delete"] = f"erro: {e}"

    all_ok = all(v == "ok" for k, v in results.items() if k not in ("buckets",))
    return JSONResponse(
        {
            "status": "ok" if all_ok else "parcial",
            "endpoint": envs.MINIO_ENDPOINT,
            "detalhes": results,
        },
        status_code=200 if all_ok else 207,
    )
