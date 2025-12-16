"""Serviço para upload de imagens no Supabase Storage"""

import os
from typing import Optional
from loguru import logger
from supabase import create_client, Client
from dotenv import load_dotenv

import envs

load_dotenv()


class SupabaseService:
    """Serviço para upload de imagens no Supabase Storage"""
    
    def __init__(self):
        """Inicializa o cliente do Supabase com credenciais do .env"""
        self.url = envs.SUPABASE_URL
        self.key = envs.SUPABASE_KEY
        self.bucket = envs.SUPABASE_BUCKET
        
        if not self.url or not self.key:
            raise ValueError(
                "SUPABASE_URL e SUPABASE_KEY devem estar configurados no arquivo .env"
            )
        
        # Valida e loga a configuração
        logger.info(f"Inicializando cliente Supabase...")
        logger.info(f"URL: {self.url}")
        logger.info(f"Bucket: {self.bucket}")
        logger.debug(f"Key (primeiros 20 chars): {self.key[:20]}...")
        
        # Valida formato da URL
        if not self.url.startswith('https://') or '.supabase.co' not in self.url:
            raise ValueError(
                f"URL do Supabase inválida: {self.url}. "
                f"Deve ser no formato: https://[project-id].supabase.co"
            )
        
        try:
            self.client: Client = create_client(self.url, self.key)
            logger.info(f"✅ Cliente Supabase inicializado com sucesso. Bucket: {self.bucket}")
        except Exception as e:
            logger.error(f"❌ Erro ao inicializar cliente Supabase: {e}")
            logger.error(f"URL usada: {self.url}")
            logger.error(f"Verifique se a URL e a chave estão corretas")
            raise
    
    def upload_image(self, file_name: str, file_bytes: bytes, content_type: str = "image/jpeg") -> Optional[str]:
        """
        Faz upload de uma imagem para o Supabase Storage
        
        Args:
            file_name: Nome do arquivo (ex: produtos/123.jpg) - deve seguir formato folder/subfolder/filename.ext
            file_bytes: Bytes da imagem
            content_type: Tipo MIME da imagem (padrão: image/jpeg)
            
        Returns:
            URL pública do arquivo ou None em caso de erro
        """
        try:
            # Garante que o path segue o formato folder/subfolder/filename.ext
            # Se não tiver pasta, coloca na pasta 'produtos'
            if '/' not in file_name:
                path = f"produtos/{file_name}"
            else:
                path = file_name
            
            logger.info(f"Fazendo upload de {path} para Supabase Storage (bucket: {self.bucket})")
            logger.info(f"URL do Supabase: {self.url}")
            logger.info(f"Tamanho da imagem: {len(file_bytes)} bytes")
            
            # Verifica se o cliente está inicializado
            if not hasattr(self, 'client') or self.client is None:
                logger.error("Cliente Supabase não está inicializado!")
                return None
            
            # Prepara opções conforme documentação oficial do Supabase
            # Formato: upload(file_path, file, options)
            # Opções: 'upsert': 'true' (string) e 'content-type': 'image/jpeg' (com hífen)
            options = {
                'upsert': 'true',  # Permite sobrescrever arquivos existentes (string)
                'content-type': content_type  # Tipo MIME explícito (com hífen)
            }
            
            # Faz upload do arquivo usando o SDK conforme documentação oficial
            # O SDK aceita bytes diretamente ou um objeto file-like
            # Formato: supabase.storage.from_('bucket_name').upload('file_path', file, options)
            response = self.client.storage.from_(self.bucket).upload(
                path,  # file_path (primeiro parâmetro)
                file_bytes,  # file (segundo parâmetro) - bytes diretamente
                options  # opções como terceiro parâmetro (dicionário)
            )
            
            logger.info(f"Upload realizado com sucesso. Response: {response}")
            
            # Obtém URL pública usando o método do SDK
            public_url = self.get_public_url(path)
            
            logger.info(f"URL pública gerada: {public_url}")
            return public_url
            
        except Exception as e:
            # Converte erro para string de forma segura (evita KeyError em dicionários)
            try:
                error_msg = str(e)
                error_repr = repr(e)
            except Exception:
                error_msg = "Erro desconhecido"
                error_repr = str(type(e))
            
            # Detecta erros de autenticação (chave inválida)
            if "Invalid Compact JWS" in error_msg or "Unauthorized" in error_msg or ("403" in error_msg and "statusCode" in error_repr):
                logger.error("❌ Erro de autenticação no Supabase: Chave inválida ou expirada")
                logger.error(f"Verifique se a SUPABASE_KEY está correta no arquivo .env")
                logger.error(f"URL usada: {self.url}")
                logger.error(f"Erro completo: {error_repr}")
                return None
            
            # Detecta erros de DNS/conectividade
            if "Name or service not known" in error_msg or "Failed to resolve" in error_msg or "gaierror" in error_msg.lower():
                logger.error(f"❌ Erro de DNS/conectividade ao acessar Supabase. Verifique a conectividade de rede e a URL: {self.url}")
                logger.error(f"Detalhes do erro: {error_repr}")
            else:
                logger.error(f"❌ Erro ao fazer upload de imagem no Supabase: {error_repr}")
                logger.error(f"Tipo do erro: {type(e).__name__}")
            return None
    
    def upload_file(self, file_name: str, file_bytes: bytes, content_type: str = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") -> Optional[str]:
        """
        Faz upload de um arquivo genérico para o Supabase Storage
        
        Args:
            file_name: Nome do arquivo (ex: planilhas/produtos_atualizados.xlsx)
            file_bytes: Bytes do arquivo
            content_type: Tipo MIME do arquivo (padrão: Excel)
            
        Returns:
            URL pública do arquivo ou None em caso de erro
        """
        try:
            # Garante que o path segue o formato folder/subfolder/filename.ext
            # Se não tiver pasta, coloca na pasta 'planilhas'
            if '/' not in file_name:
                path = f"planilhas/{file_name}"
            else:
                path = file_name
            
            logger.info(f"Fazendo upload de {path} para Supabase Storage (bucket: {self.bucket})")
            logger.debug(f"URL do Supabase: {self.url}, Tamanho do arquivo: {len(file_bytes)} bytes")
            
            # Prepara opções conforme documentação oficial do Supabase
            options = {
                'upsert': 'true',  # Permite sobrescrever arquivos existentes (string)
                'content-type': content_type  # Tipo MIME explícito (com hífen)
            }
            
            # Faz upload do arquivo usando o SDK conforme documentação oficial
            response = self.client.storage.from_(self.bucket).upload(
                path,  # file_path (primeiro parâmetro)
                file_bytes,  # file (segundo parâmetro) - bytes diretamente
                options  # opções como terceiro parâmetro (dicionário)
            )
            
            logger.info(f"Upload realizado com sucesso. Response: {response}")
            
            # Obtém URL pública usando o método do SDK
            public_url = self.get_public_url(path)
            
            logger.info(f"URL pública gerada: {public_url}")
            return public_url
            
        except Exception as e:
            # Converte erro para string de forma segura (evita KeyError em dicionários)
            try:
                error_msg = str(e)
                error_repr = repr(e)
            except Exception:
                error_msg = "Erro desconhecido"
                error_repr = str(type(e))
            
            # Detecta erros de autenticação (chave inválida)
            if "Invalid Compact JWS" in error_msg or "Unauthorized" in error_msg or ("403" in error_msg and "statusCode" in error_repr):
                logger.error("❌ Erro de autenticação no Supabase: Chave inválida ou expirada")
                logger.error(f"Verifique se a SUPABASE_KEY está correta no arquivo .env")
                logger.error(f"URL usada: {self.url}")
                logger.error(f"Erro completo: {error_repr}")
                return None
            
            # Detecta erros de DNS/conectividade
            if "Name or service not known" in error_msg or "Failed to resolve" in error_msg or "gaierror" in error_msg.lower():
                logger.error(f"❌ Erro de DNS/conectividade ao acessar Supabase. Verifique a conectividade de rede e a URL: {self.url}")
                logger.error(f"Detalhes do erro: {error_repr}")
            else:
                logger.error(f"❌ Erro ao fazer upload de arquivo no Supabase: {error_repr}")
                logger.error(f"Tipo do erro: {type(e).__name__}")
            return None
    
    def delete_all_images_in_folder(self, folder: str = "produtos") -> bool:
        """
        Deleta todos os arquivos de uma pasta no Supabase Storage
        
        Args:
            folder: Nome da pasta (ex: "produtos")
            
        Returns:
            True se deletou com sucesso, False caso contrário
        """
        try:
            logger.info(f"Deletando todos os arquivos da pasta {folder} no Supabase Storage")
            
            # Lista todos os arquivos na pasta
            files = self.client.storage.from_(self.bucket).list(path=folder)
            
            if not files:
                logger.info(f"Pasta {folder} está vazia")
                return True
            
            deleted_count = 0
            file_paths = []
            
            # Coleta todos os paths dos arquivos
            for file_info in files:
                if file_info.get('name'):  # Ignora pastas
                    file_path = f"{folder}/{file_info['name']}"
                    file_paths.append(file_path)
            
            if not file_paths:
                logger.info(f"Nenhum arquivo encontrado na pasta {folder}")
                return True
            
            # Deleta todos os arquivos de uma vez (mais eficiente)
            try:
                self.client.storage.from_(self.bucket).remove(file_paths)
                deleted_count = len(file_paths)
                logger.info(f"Deletados {deleted_count} arquivo(s) da pasta {folder}")
            except Exception as e:
                logger.warning(f"Erro ao deletar em lote, tentando individualmente: {e}")
                # Fallback: deleta um por um
                for file_path in file_paths:
                    try:
                        self.client.storage.from_(self.bucket).remove([file_path])
                        deleted_count += 1
                        logger.debug(f"Arquivo deletado: {file_path}")
                    except Exception as e2:
                        logger.warning(f"Erro ao deletar arquivo {file_path}: {e2}")
                        continue
            
            logger.info(f"Total de {deleted_count} arquivo(s) deletado(s) da pasta {folder}")
            return True
            
        except Exception as e:
            logger.error(f"Erro ao deletar arquivos do Supabase: {e}", exc_info=True)
            return False
    
    def get_public_url(self, path: str) -> str:
        """
        Gera URL pública de um arquivo no Supabase Storage
        
        CAMINHO 3: NUNCA constrói URL manualmente - apenas usa URLs que o SDK retorna
        Se o arquivo não existe no Storage, retorna None (não gera URL fantasma)
        
        Args:
            path: Caminho do arquivo (ex: produtos/123.jpg)
            
        Returns:
            URL pública do arquivo ou None se não conseguir obter
        """
        try:
            # CAMINHO 3: Usa APENAS o método do SDK - fonte única da verdade
            public_url = self.client.storage.from_(self.bucket).get_public_url(path)
            logger.debug(f"URL pública obtida do Storage para {path}: {public_url}")
            return public_url
        except Exception as e:
            logger.error(f"❌ Erro ao obter URL pública do Storage para {path}: {e}")
            logger.error("CAMINHO 3: Não gerando URL manualmente - arquivo pode não existir no Storage")
            # CAMINHO 3: Retorna None em vez de construir URL fantasma
            return None
    
    def file_exists(self, path: str, timeout: int = 5) -> bool:
        """
        Verifica se um arquivo existe no Supabase Storage
        
        CAMINHO 1: Storage é a fonte única da verdade
        Se o arquivo não está no Storage, ele não existe
        
        NOTA: Este método pode ser lento. Use com cuidado em loops.
        Para uploads recentes, confie no retorno do upload() em vez de validar.
        
        Args:
            path: Caminho do arquivo (ex: produtos/123.jpg)
            timeout: Timeout em segundos (padrão: 5)
            
        Returns:
            True se o arquivo existe, False caso contrário ou em caso de erro/timeout
        """
        try:
            import signal
            
            # Usa timeout para evitar travar a aplicação
            def timeout_handler(signum, frame):
                raise TimeoutError(f"Timeout ao verificar existência do arquivo {path}")
            
            # Configura timeout (apenas em sistemas Unix)
            try:
                signal.signal(signal.SIGALRM, timeout_handler)
                signal.alarm(timeout)
            except (AttributeError, OSError):
                # Windows não suporta SIGALRM, ignora timeout
                pass
            
            try:
                # Tenta listar o arquivo específico
                # NOTA: list() pode ser lento - considere usar apenas após upload
                files = self.client.storage.from_(self.bucket).list(path=path)
                # Se retornou algo, o arquivo existe
                exists = len(files) > 0
                logger.debug(f"Verificação de existência para {path}: {'existe' if exists else 'não existe'}")
                return exists
            finally:
                # Cancela o alarme
                try:
                    signal.alarm(0)
                except (AttributeError, OSError):
                    pass
        except TimeoutError:
            logger.warning(f"Timeout ao verificar existência do arquivo {path} (>{timeout}s)")
            return False
        except Exception as e:
            logger.warning(f"Erro ao verificar existência do arquivo {path}: {e}")
            return False

