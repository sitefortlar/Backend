"""Use case para upload de planilha Excel com processamento de imagens"""

import io
import json
import datetime
import hashlib
import pandas as pd
from typing import Dict, Any, Optional, List
from loguru import logger

from app.application.usecases.use_case import UseCase
from app.application.service.drive_service import DriveService
from app.application.service.supabase_service import SupabaseService


class UploadPlanilhaUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Use case para processar planilha Excel e fazer upload de imagens"""
    
    def __init__(self):
        """Inicializa os serviços necessários"""
        self.drive_service = DriveService()
        self.supabase_service = SupabaseService()
        # Cache do run (planilha): evita upload repetido de imagens iguais dentro do mesmo processamento
        self._shared_image_cache: Dict[str, str] = {}

    def _image_key(self, original_url: str, download_url: str) -> str:
        file_id = self.drive_service.extract_drive_file_id(original_url) or self.drive_service.extract_drive_file_id(download_url)
        if file_id:
            return f"drive_{file_id}"
        base = (download_url or original_url or "").strip()
        h = hashlib.sha1(base.encode("utf-8")).hexdigest()
        return f"url_{h}"

    def _shared_object_path(self, key: str) -> str:
        return f"produtos/shared/{key}.jpg"
    
    def _parse_image_urls(self, imagem_url: str) -> List[str]:
        """
        Parseia a coluna imagem_url que pode ser:
        - Uma URL única: "https://drive.google.com/..."
        - Um array de URLs: "[url1, url2, url3]" ou "[url1, url2, url3]"
        
        Args:
            imagem_url: String com URL única ou array de URLs
            
        Returns:
            Lista de URLs
        """
        try:
            imagem_url = str(imagem_url).strip()
            
            # Se estiver vazio
            if not imagem_url or imagem_url.lower() in ['nan', 'none', '']:
                return []
            
            # Se começar com [, é um array
            if imagem_url.startswith('[') and imagem_url.endswith(']'):
                # Remove colchetes
                content = imagem_url[1:-1].strip()
                
                # Tenta parsear como JSON primeiro
                try:
                    parsed = json.loads(imagem_url)
                    if isinstance(parsed, list):
                        return [url.strip() for url in parsed if url and str(url).strip()]
                except (json.JSONDecodeError, ValueError):
                    pass
                
                # Se não for JSON válido, separa por vírgula
                urls = [url.strip() for url in content.split(',') if url.strip()]
                return urls
            
            # Se não for array, retorna como lista com um único item
            return [imagem_url]
            
        except Exception as e:
            logger.error(f"Erro ao parsear URLs: {e}")
            return []
    
    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        """
        Executa o processamento da planilha
        
        Args:
            request: Dicionário contendo 'file_bytes' (bytes do arquivo Excel)
            session: Não utilizado neste use case
            
        Returns:
            Dicionário com URL do Excel no Supabase e estatísticas do processamento
            
        Raises:
            ValueError: Se a planilha não tiver as colunas necessárias
            Exception: Em caso de erro no processamento
        """
        try:
            file_bytes = request.get('file_bytes')
            if not file_bytes:
                raise ValueError("file_bytes é obrigatório")
            
            logger.info("Iniciando processamento da planilha")
            
            # Lê a planilha Excel
            df = pd.read_excel(io.BytesIO(file_bytes))
            
            # Valida colunas obrigatórias
            required_columns = ['codigo', 'nome', 'imagem_url']
            missing_columns = [col for col in required_columns if col not in df.columns]
            
            if missing_columns:
                raise ValueError(
                    f"Planilha deve conter as colunas: {required_columns}. "
                    f"Colunas faltando: {missing_columns}"
                )
            
            logger.info(f"Planilha lida com sucesso. {len(df)} linhas encontradas")
            
            # Inicializa coluna de links do Supabase
            df['imagem_supabase'] = ''
            
            # Processa cada linha
            success_count = 0
            error_count = 0
            total_imagens_processadas = 0
            
            for index, row in df.iterrows():
                try:
                    codigo = str(row['codigo']).strip()
                    nome = str(row['nome']).strip()
                    imagem_url_raw = str(row['imagem_url']).strip()
                    
                    # Parseia URLs (pode ser uma URL única ou array)
                    image_urls = self._parse_image_urls(imagem_url_raw)
                    
                    # Pula linhas vazias
                    if not image_urls:
                        logger.warning(f"Linha {index + 1}: URL de imagem vazia, pulando")
                        continue
                    
                    logger.info(f"Processando linha {index + 1}: {codigo} - {nome} ({len(image_urls)} imagem(ns))")
                    
                    # Lista para armazenar os links do Supabase
                    supabase_urls = []
                    linha_success = 0
                    linha_errors = 0
                    
                    # Processa cada URL do array
                    for img_idx, imagem_url in enumerate(image_urls, 1):
                        try:
                            logger.info(f"Linha {index + 1}, Imagem {img_idx}/{len(image_urls)}: Processando {imagem_url[:50]}...")
                            
                            # Converte link do Google Drive
                            download_url = self.drive_service.convert_drive_link(imagem_url)
                            if not download_url:
                                logger.error(f"Linha {index + 1}, Imagem {img_idx}: Não foi possível converter o link do Google Drive")
                                linha_errors += 1
                                continue
                            
                            # Verifica se a URL já é do Supabase
                            is_supabase_url = 'supabase.co' in download_url or 'supabase' in download_url.lower()
                            
                            if is_supabase_url:
                                # URL já é do Supabase, não precisa fazer download/upload
                                logger.info(f"Linha {index + 1}, Imagem {img_idx}: URL já é do Supabase, usando diretamente")
                                supabase_url = download_url
                            else:
                                # Dedupe dentro do processamento da planilha
                                key = self._image_key(original_url=imagem_url, download_url=download_url)
                                cached = self._shared_image_cache.get(key)
                                if cached:
                                    supabase_url = cached
                                    logger.info(f"Linha {index + 1}, Imagem {img_idx}: Dedupe cache_hit=1")
                                else:
                                    object_path = self._shared_object_path(key)

                                    # Faz download da imagem do Google Drive (com retry/backoff)
                                    image_bytes, content_type = self.drive_service.download_image_with_meta(download_url)
                                    if not image_bytes:
                                        logger.error(f"Linha {index + 1}, Imagem {img_idx}: Falha no download da imagem")
                                        linha_errors += 1
                                        continue
                                    
                                    logger.info(f"Linha {index + 1}, Imagem {img_idx}: Download concluído ({len(image_bytes)} bytes)")
                                    
                                    # Faz upload para o Supabase usando path determinístico (reuso entre linhas)
                                    supabase_url = self.supabase_service.upload_image(
                                        file_name=object_path,
                                        file_bytes=image_bytes,
                                        content_type=content_type or "image/jpeg"
                                    )
                                    
                                    if not supabase_url:
                                        logger.error(f"Linha {index + 1}, Imagem {img_idx}: Não foi possível fazer upload no Supabase")
                                        linha_errors += 1
                                        continue

                                    self._shared_image_cache[key] = supabase_url
                            
                            supabase_urls.append(supabase_url)
                            linha_success += 1
                            total_imagens_processadas += 1
                            
                            logger.info(f"Linha {index + 1}, Imagem {img_idx}: Upload concluído - {supabase_url}")
                            
                        except Exception as e:
                            logger.error(f"Erro ao processar imagem {img_idx} da linha {index + 1}: {e}")
                            linha_errors += 1
                            continue
                    
                    # Atualiza a planilha com o array de links do Supabase no mesmo formato
                    if supabase_urls:
                        # Formata como array: [url1, url2, url3]
                        supabase_urls_str = '[' + ', '.join(supabase_urls) + ']'
                        df.at[index, 'imagem_supabase'] = supabase_urls_str
                        success_count += 1
                        logger.info(f"Linha {index + 1}: Processada com sucesso - {linha_success} imagem(ns) salva(s)")
                    else:
                        logger.warning(f"Linha {index + 1}: Nenhuma imagem foi processada com sucesso")
                        error_count += 1
                    
                    if linha_errors > 0:
                        error_count += linha_errors
                    
                except Exception as e:
                    logger.error(f"Erro ao processar linha {index + 1}: {e}")
                    error_count += 1
                    continue
            
            logger.info(
                f"Processamento concluído: {success_count} linhas processadas, "
                f"{total_imagens_processadas} imagens salvas, {error_count} erros"
            )
            
            # Cria novo arquivo Excel em memória
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='openpyxl') as writer:
                df.to_excel(writer, index=False, sheet_name='Produtos')
            
            output.seek(0)
            result_bytes = output.read()
            
            logger.info(f"Arquivo Excel gerado: {len(result_bytes)} bytes")
            
            # Faz upload do Excel para o Supabase
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            excel_file_name = f"produtos_com_links_{timestamp}.xlsx"
            
            logger.info(f"Fazendo upload do Excel atualizado para Supabase: {excel_file_name}")
            excel_url = self.supabase_service.upload_file(
                file_name=excel_file_name,
                file_bytes=result_bytes,
                content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            
            if not excel_url:
                raise Exception("Não foi possível fazer upload do Excel no Supabase")
            
            logger.info(f"Excel salvo no Supabase: {excel_url}")
            
            # Retorna dicionário com URL e estatísticas
            return {
                "excel_url": excel_url,
                "excel_filename": excel_file_name,
                "total_linhas": len(df),
                "linhas_processadas": success_count,
                "total_imagens_salvas": total_imagens_processadas,
                "erros": error_count,
                "mensagem": f"Processamento concluído: {success_count} linhas processadas, {total_imagens_processadas} imagens salvas, {error_count} erros"
            }
            
        except ValueError as e:
            logger.error(f"Erro de validação: {e}")
            raise
        except Exception as e:
            logger.error(f"Erro inesperado no processamento: {e}")
            raise Exception(f"Erro ao processar planilha: {str(e)}")

