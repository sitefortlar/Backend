"""Utilitários para manipulação de arquivos"""

import io
from typing import Optional
from loguru import logger


def get_file_extension_from_content_type(content_type: str) -> str:
    """
    Retorna extensão de arquivo baseado no Content-Type
    
    Args:
        content_type: Tipo MIME (ex: image/jpeg, image/png)
        
    Returns:
        Extensão do arquivo (ex: .jpg, .png)
    """
    content_type_map = {
        'image/jpeg': '.jpg',
        'image/jpg': '.jpg',
        'image/png': '.png',
        'image/gif': '.gif',
        'image/webp': '.webp',
        'image/bmp': '.bmp'
    }
    
    return content_type_map.get(content_type.lower(), '.jpg')


def validate_excel_file(filename: str) -> bool:
    """
    Valida se o arquivo é um Excel válido
    
    Args:
        filename: Nome do arquivo
        
    Returns:
        True se for um arquivo Excel válido
    """
    valid_extensions = ['.xlsx', '.xls']
    return any(filename.lower().endswith(ext) for ext in valid_extensions)


