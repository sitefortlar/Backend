"""Serviço para manipulação de links do Google Drive"""

import re
import time
from typing import Optional, Tuple

import requests
from loguru import logger


class DriveService:
    """Serviço para converter links do Google Drive e fazer download de imagens"""
    
    @staticmethod
    def convert_drive_link(google_drive_url: str) -> Optional[str]:
        """
        Converte link do Google Drive para formato direto de download
        
        Suporta os seguintes formatos:
        - https://drive.google.com/file/d/FILE_ID/view?usp=sharing
        - https://drive.google.com/open?id=FILE_ID
        - https://drive.google.com/uc?id=FILE_ID
        - https://drive.google.com/file/d/FILE_ID/edit
        - URLs do Supabase (retorna como está)
        
        Args:
            google_drive_url: URL do Google Drive ou Supabase
            
        Returns:
            URL de download direto ou None se não conseguir extrair o ID
        """
        try:
            # Verifica se já é uma URL do Supabase
            if 'supabase.co' in google_drive_url or 'supabase' in google_drive_url.lower():
                logger.debug(f"URL já é do Supabase, retornando como está: {google_drive_url[:80]}...")
                return google_drive_url
            
            # Padrão 1: /file/d/FILE_ID/
            match = re.search(r'/file/d/([a-zA-Z0-9_-]+)', google_drive_url)
            if match:
                file_id = match.group(1)
                return f"https://drive.google.com/uc?export=download&id={file_id}"
            
            # Padrão 2: ?id=FILE_ID
            match = re.search(r'[?&]id=([a-zA-Z0-9_-]+)', google_drive_url)
            if match:
                file_id = match.group(1)
                return f"https://drive.google.com/uc?export=download&id={file_id}"
            
            # Se já estiver no formato direto, retorna como está
            if 'uc?export=download&id=' in google_drive_url:
                return google_drive_url
            
            logger.warning(f"Não foi possível extrair ID do link: {google_drive_url}")
            return None
            
        except Exception as e:
            logger.error(f"Erro ao converter link do Google Drive: {e}")
            return None
    
    @staticmethod
    def extract_drive_file_id(url: str) -> Optional[str]:
        """
        Extrai o FILE_ID de um link do Google Drive (vários formatos suportados).
        Retorna None se não conseguir identificar.
        """
        try:
            if not url:
                return None

            # Padrão 1: /file/d/FILE_ID/
            match = re.search(r'/file/d/([a-zA-Z0-9_-]+)', url)
            if match:
                return match.group(1)

            # Padrão 2: ?id=FILE_ID (open?id= / uc?id=)
            match = re.search(r'[?&]id=([a-zA-Z0-9_-]+)', url)
            if match:
                return match.group(1)

            # Padrão 3: uc?export=download&id=FILE_ID
            match = re.search(r'uc\?export=download&id=([a-zA-Z0-9_-]+)', url)
            if match:
                return match.group(1)

            return None
        except Exception:
            return None

    @staticmethod
    def download_image_with_meta(
        url: str,
        timeout: int = 30,
        max_attempts: int = 4,
        max_bytes: int = 15_000_000
    ) -> Tuple[Optional[bytes], Optional[str]]:
        """
        Faz download de uma imagem e retorna (bytes, content_type).

        - Usa retry/backoff para erros transitórios (429/5xx, timeout, conexão).
        - Valida Content-Type começando com 'image/'.
        - Protege contra arquivos muito grandes via max_bytes.
        """
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }

        last_error: Optional[Exception] = None
        for attempt in range(1, max_attempts + 1):
            try:
                logger.info(f"[DRIVE] download attempt={attempt}/{max_attempts} url={url}")

                # timeout como (connect, read)
                resp = requests.get(url, headers=headers, timeout=(5, timeout), stream=True)
                resp.raise_for_status()

                content_type = (resp.headers.get('Content-Type', '') or '').split(';')[0].strip().lower()
                if not content_type.startswith('image/'):
                    logger.warning(f"[DRIVE] content_type_not_image content_type='{content_type}' url={url}")
                    return None, None

                size = 0
                chunks = []
                for chunk in resp.iter_content(chunk_size=64 * 1024):
                    if not chunk:
                        continue
                    size += len(chunk)
                    if size > max_bytes:
                        logger.error(f"[DRIVE] image_too_large bytes={size} limit={max_bytes} url={url}")
                        return None, None
                    chunks.append(chunk)

                image_bytes = b"".join(chunks)
                logger.info(f"[DRIVE] download_ok bytes={len(image_bytes)} content_type={content_type}")
                return image_bytes, content_type

            except requests.exceptions.HTTPError as e:
                last_error = e
                status_code = getattr(e.response, "status_code", None)
                retryable = status_code in (429, 500, 502, 503, 504)
                logger.warning(f"[DRIVE] http_error status={status_code} retryable={retryable} err={e}")

                if retryable and attempt < max_attempts:
                    backoff = min(2 ** (attempt - 1), 10)
                    time.sleep(backoff)
                    continue
                return None, None

            except (requests.exceptions.Timeout, requests.exceptions.ConnectionError) as e:
                last_error = e
                logger.warning(f"[DRIVE] net_error retryable=1 err={e}")
                if attempt < max_attempts:
                    backoff = min(2 ** (attempt - 1), 10)
                    time.sleep(backoff)
                    continue
                return None, None

            except requests.exceptions.RequestException as e:
                last_error = e
                logger.error(f"[DRIVE] request_error err={e}")
                return None, None

            except Exception as e:
                last_error = e
                logger.error(f"[DRIVE] unexpected_error err={e}", exc_info=True)
                return None, None

        logger.error(f"[DRIVE] download_failed err={last_error}")
        return None, None

    @staticmethod
    def download_image(url: str, timeout: int = 30) -> Optional[bytes]:
        """
        Faz download de uma imagem a partir de uma URL
        
        Args:
            url: URL da imagem
            timeout: Timeout em segundos para o download
            
        Returns:
            Bytes da imagem ou None em caso de erro
        """
        image_bytes, _content_type = DriveService.download_image_with_meta(url=url, timeout=timeout)
        return image_bytes


