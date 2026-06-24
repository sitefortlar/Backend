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
from app.application.service.storage_service import StorageService


class UploadPlanilhaUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Use case para processar planilha Excel e fazer upload de imagens"""

    def __init__(self):
        self.drive_service = DriveService()
        self.storage_service = StorageService()
        # Cache do run: evita upload repetido de imagens iguais dentro do mesmo processamento
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
        """Parseia a coluna imagem_url (URL única ou array '[url1, url2]')."""
        try:
            imagem_url = str(imagem_url).strip()
            if not imagem_url or imagem_url.lower() in ['nan', 'none', '']:
                return []

            if imagem_url.startswith('[') and imagem_url.endswith(']'):
                content = imagem_url[1:-1].strip()
                try:
                    parsed = json.loads(imagem_url)
                    if isinstance(parsed, list):
                        return [url.strip() for url in parsed if url and str(url).strip()]
                except (json.JSONDecodeError, ValueError):
                    pass
                return [url.strip() for url in content.split(',') if url.strip()]

            return [imagem_url]
        except Exception as e:
            logger.error(f"Erro ao parsear URLs: {e}")
            return []

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        """
        Executa o processamento da planilha.

        Args:
            request: Dicionário contendo 'file_bytes' (bytes do arquivo Excel)
            session: Não utilizado neste use case

        Returns:
            Dicionário com URL do Excel gerado e estatísticas do processamento
        """
        try:
            file_bytes = request.get('file_bytes')
            if not file_bytes:
                raise ValueError("file_bytes é obrigatório")

            logger.info("Iniciando processamento da planilha")

            df = pd.read_excel(io.BytesIO(file_bytes))

            required_columns = ['codigo', 'nome', 'imagem_url']
            missing_columns = [col for col in required_columns if col not in df.columns]
            if missing_columns:
                raise ValueError(
                    f"Planilha deve conter as colunas: {required_columns}. "
                    f"Colunas faltando: {missing_columns}"
                )

            logger.info(f"Planilha lida com sucesso. {len(df)} linhas encontradas")

            df['imagem_storage'] = ''

            success_count = 0
            error_count = 0
            total_imagens_processadas = 0

            for index, row in df.iterrows():
                try:
                    codigo = str(row['codigo']).strip()
                    nome = str(row['nome']).strip()
                    imagem_url_raw = str(row['imagem_url']).strip()

                    image_urls = self._parse_image_urls(imagem_url_raw)

                    if not image_urls:
                        logger.warning(f"Linha {index + 1}: URL de imagem vazia, pulando")
                        continue

                    logger.info(f"Processando linha {index + 1}: {codigo} - {nome} ({len(image_urls)} imagem(ns))")

                    storage_urls = []
                    linha_success = 0
                    linha_errors = 0

                    for img_idx, imagem_url in enumerate(image_urls, 1):
                        try:
                            logger.info(f"Linha {index + 1}, Imagem {img_idx}/{len(image_urls)}: Processando {imagem_url[:50]}...")

                            download_url = self.drive_service.convert_drive_link(imagem_url)
                            if not download_url:
                                logger.error(f"Linha {index + 1}, Imagem {img_idx}: Não foi possível converter o link")
                                linha_errors += 1
                                continue

                            # URL já é do storage (MinIO proxy ou legado local) — usa diretamente sem re-upload
                            is_stored_url = '/api/media/' in download_url or '/uploads/' in download_url

                            if is_stored_url:
                                logger.info(f"Linha {index + 1}, Imagem {img_idx}: URL já é local, usando diretamente")
                                storage_url = download_url
                            else:
                                key = self._image_key(original_url=imagem_url, download_url=download_url)
                                cached = self._shared_image_cache.get(key)
                                if cached:
                                    storage_url = cached
                                    logger.info(f"Linha {index + 1}, Imagem {img_idx}: Dedupe cache_hit=1")
                                else:
                                    object_path = self._shared_object_path(key)

                                    image_bytes, content_type = self.drive_service.download_image_with_meta(download_url)
                                    if not image_bytes:
                                        logger.error(f"Linha {index + 1}, Imagem {img_idx}: Falha no download da imagem")
                                        linha_errors += 1
                                        continue

                                    logger.info(f"Linha {index + 1}, Imagem {img_idx}: Download concluído ({len(image_bytes)} bytes)")

                                    storage_url = self.storage_service.upload_image(
                                        file_name=object_path,
                                        file_bytes=image_bytes,
                                        content_type=content_type or "image/jpeg"
                                    )

                                    if not storage_url:
                                        logger.error(f"Linha {index + 1}, Imagem {img_idx}: Falha no upload para storage local")
                                        linha_errors += 1
                                        continue

                                    self._shared_image_cache[key] = storage_url

                            storage_urls.append(storage_url)
                            linha_success += 1
                            total_imagens_processadas += 1

                            logger.info(f"Linha {index + 1}, Imagem {img_idx}: Upload concluído - {storage_url}")

                        except Exception as e:
                            logger.error(f"Erro ao processar imagem {img_idx} da linha {index + 1}: {e}")
                            linha_errors += 1
                            continue

                    if storage_urls:
                        storage_urls_str = '[' + ', '.join(storage_urls) + ']'
                        df.at[index, 'imagem_storage'] = storage_urls_str
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

            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='openpyxl') as writer:
                df.to_excel(writer, index=False, sheet_name='Produtos')

            output.seek(0)
            result_bytes = output.read()

            logger.info(f"Arquivo Excel gerado: {len(result_bytes)} bytes")

            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            excel_file_name = f"produtos_com_links_{timestamp}.xlsx"

            logger.info(f"Salvando Excel atualizado no storage local: {excel_file_name}")
            excel_url = self.storage_service.upload_file(
                file_name=excel_file_name,
                file_bytes=result_bytes,
                content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )

            if not excel_url:
                raise Exception("Não foi possível salvar o Excel no storage local")

            logger.info(f"Excel salvo no storage: {excel_url}")

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
