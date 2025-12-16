"""Serviço para armazenamento local de imagens baixadas do Google Drive"""

import os
import hashlib
from pathlib import Path
from typing import Optional, Set
from loguru import logger

class LocalImageService:
    """Serviço para download e armazenamento local de imagens"""
    
    def __init__(self, base_path: str = "assets", base_url: str = "/api/assets"):
        """
        Inicializa o serviço de armazenamento local
        
        Args:
            base_path: Caminho base para armazenar arquivos (relativo ao diretório raiz)
            base_url: URL base para acessar os arquivos via HTTP
        """
        self.base_path = Path(base_path)
        self.base_url = base_url.rstrip('/')
        self.produtos_path = self.base_path / "produtos"
        
        # Cria a estrutura de pastas
        self.produtos_path.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"✅ LocalImageService inicializado")
        logger.info(f"Pasta base: {self.base_path.absolute()}")
        logger.info(f"URL base: {self.base_url}")
    
    def _generate_file_hash(self, url: str) -> str:
        """
        Gera hash único baseado na URL para evitar duplicatas
        
        Args:
            url: URL da imagem
            
        Returns:
            Hash MD5 da URL
        """
        return hashlib.md5(url.encode()).hexdigest()
    
    def _get_file_name(self, produto_codigo: str, url: str, index: int, total: int) -> str:
        """
        Gera nome do arquivo baseado no código do produto e hash da URL
        
        Args:
            produto_codigo: Código do produto
            url: URL original da imagem
            index: Índice da imagem (1-based)
            total: Total de imagens
            
        Returns:
            Nome do arquivo (ex: 123.jpg ou 123_1.jpg)
        """
        # Gera hash curto da URL para evitar nomes muito longos
        url_hash = self._generate_file_hash(url)[:8]
        
        if total == 1:
            return f"{produto_codigo}.jpg"
        else:
            return f"{produto_codigo}_{index}.jpg"
    
    def save_image_from_bytes(
        self, 
        produto_codigo: str, 
        image_bytes: bytes, 
        original_url: str,
        index: int = 1,
        total: int = 1
    ) -> Optional[str]:
        """
        Salva imagem localmente e retorna URL pública
        
        Args:
            produto_codigo: Código do produto
            image_bytes: Bytes da imagem
            original_url: URL original do Google Drive (para hash/verificação)
            index: Índice da imagem (1-based)
            total: Total de imagens do produto
            
        Returns:
            URL pública do arquivo ou None em caso de erro
        """
        try:
            # Gera nome do arquivo
            file_name = self._get_file_name(produto_codigo, original_url, index, total)
            file_path = self.produtos_path / file_name
            
            # Verifica se arquivo já existe (evita sobrescrever)
            if file_path.exists():
                logger.debug(f"Arquivo já existe: {file_path}, usando existente")
                url_path = f"produtos/{file_name}"
                public_url = f"{self.base_url}/{url_path}"
                return public_url
            
            # Salva o arquivo
            with open(file_path, 'wb') as f:
                f.write(image_bytes)
            
            # Gera URL pública
            url_path = f"produtos/{file_name}"
            public_url = f"{self.base_url}/{url_path}"
            
            logger.info(f"✅ Imagem salva: {file_path} ({len(image_bytes)} bytes)")
            logger.info(f"   URL: {public_url}")
            
            return public_url
            
        except Exception as e:
            logger.error(f"❌ Erro ao salvar imagem localmente: {e}", exc_info=True)
            return None
    
    def delete_image(self, url: str) -> bool:
        """
        Deleta uma imagem pelo URL
        
        Args:
            url: URL da imagem (ex: /api/assets/produtos/123.jpg)
            
        Returns:
            True se deletou com sucesso, False caso contrário
        """
        try:
            # Extrai o nome do arquivo da URL
            if '/produtos/' in url:
                file_name = url.split('/produtos/')[-1]
            elif url.startswith('/api/assets/'):
                file_name = url.replace('/api/assets/produtos/', '')
            else:
                file_name = url.split('/')[-1]
            
            file_path = self.produtos_path / file_name
            if file_path.exists():
                file_path.unlink()
                logger.info(f"✅ Arquivo deletado: {file_path}")
                return True
            else:
                logger.warning(f"Arquivo não encontrado: {file_path}")
                return False
        except Exception as e:
            logger.error(f"❌ Erro ao deletar arquivo: {e}", exc_info=True)
            return False
    
    def delete_all_images(self) -> bool:
        """Deleta todas as imagens da pasta produtos"""
        try:
            deleted_count = 0
            for file_path in self.produtos_path.iterdir():
                if file_path.is_file():
                    file_path.unlink()
                    deleted_count += 1
            
            logger.info(f"✅ Deletadas {deleted_count} imagem(ns)")
            return True
        except Exception as e:
            logger.error(f"❌ Erro ao deletar imagens: {e}", exc_info=True)
            return False

