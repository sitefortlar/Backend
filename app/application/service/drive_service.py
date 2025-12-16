"""Serviço para manipulação de links do Google Drive"""

import re
import requests
from typing import Optional
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
    def download_image(url: str, timeout: int = 30) -> Optional[bytes]:
        """
        Faz download de uma imagem a partir de uma URL
        
        Args:
            url: URL da imagem
            timeout: Timeout em segundos para o download
            
        Returns:
            Bytes da imagem ou None em caso de erro
        """
        try:
            logger.info(f"Fazendo download da imagem: {url}")
            
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            
            response = requests.get(url, headers=headers, timeout=timeout, stream=True)
            response.raise_for_status()
            
            # Verifica se é uma imagem
            content_type = response.headers.get('Content-Type', '')
            if not content_type.startswith('image/'):
                logger.warning(f"URL não retorna uma imagem (Content-Type: {content_type})")
            
            image_bytes = response.content
            logger.info(f"Download concluído: {len(image_bytes)} bytes")
            
            return image_bytes
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Erro ao fazer download da imagem {url}: {e}")
            return None
        except Exception as e:
            logger.error(f"Erro inesperado ao fazer download: {e}")
            return None


