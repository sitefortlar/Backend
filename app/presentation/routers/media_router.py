"""Router proxy para arquivos armazenados no MinIO.

O MinIO nunca é exposto diretamente ao frontend — toda requisição de arquivo
passa por este endpoint, que resolve bucket + key pelo primeiro segmento do path
e serve o objeto via API.

Formato de URL:
  GET /api/media/{bucket}/{key}
  Ex: /api/media/produtos/123/abc.jpg   → bucket=produtos  key=123/abc.jpg
      /api/media/planilhas/relatorio.xlsx → bucket=planilhas key=relatorio.xlsx
"""

from fastapi import APIRouter, HTTPException, status
from fastapi.responses import Response
from loguru import logger

from app.application.service.storage_service import StorageService

media_router = APIRouter(prefix="/media", tags=["Media"])

_storage = StorageService()


@media_router.get("/{file_path:path}", include_in_schema=False)
def serve_media(file_path: str) -> Response:
    """Proxy para objetos armazenados no MinIO.

    FastAPI executa funções `def` em thread pool automaticamente,
    mantendo o event loop livre para outras requisições.
    """
    try:
        body, content_type = _storage.get_object(file_path)
        if body is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Arquivo não encontrado",
            )
        return Response(
            content=body,
            media_type=content_type,
            headers={"Cache-Control": "public, max-age=86400"},
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao servir arquivo '{file_path}': {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erro ao acessar arquivo",
        )
