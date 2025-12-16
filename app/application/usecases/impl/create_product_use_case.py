"""Use case para upload completo de planilha CSV ou Excel com kits, regiões, prazos e produtos"""

import io
import datetime
import pandas as pd
from typing import Dict, Any, List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
import logging

from app.application.usecases.use_case import UseCase
from app.application.service.excel_loader_service import ExcelLoaderService
from app.application.service.drive_service import DriveService
from app.application.service.supabase_service import SupabaseService
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.category_repository_interface import ICategoryRepository
from app.infrastructure.repositories.subcategory_repository_interface import ISubcategoryRepository
from app.infrastructure.repositories.product_image_repository_interface import IProductImageRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl
from app.infrastructure.repositories.impl.product_image_repository_impl import ProductImageRepositoryImpl

from app.domain.models.product_model import Product
from app.domain.models.product_image_model import ProductImage

logger = logging.getLogger(__name__)


class CreateProductUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Use case para upload completo de planilha CSV ou Excel"""
    
    def __init__(self):
        self.loader = ExcelLoaderService()
        self.drive_service = DriveService()
        self.supabase_service = SupabaseService()
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.category_repository: ICategoryRepository = CategoryRepositoryImpl()
        self.subcategory_repository: ISubcategoryRepository = SubcategoryRepositoryImpl()
        self.product_image_repository: IProductImageRepository = ProductImageRepositoryImpl()

    def execute(self, request: Dict[str, Any], session: Session = None) -> Dict[str, Any]:
        """
        Executa o upload completo da planilha
        
        Args:
            request: Dicionário contendo:
                - 'file_path': caminho do arquivo
                - 'file_format': 'csv' ou 'excel'
                - 'clean_before': True para limpar tudo antes (padrão: False)
            session: Sessão do banco de dados
            
        Returns:
            Dicionário com resumo da operação
        """

        file_path = request.get('file_path')
        if not file_path:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Caminho do arquivo é obrigatório"
            )

        file_format = request.get('file_format', 'auto')
        clean_before = request.get('clean_before', False)  # Nova flag para limpeza
        
        self.loader.file_format = file_format

        summary = {
            "categorias_created": 0,
            "subcategorias_created": 0,
            "produtos_created": 0,
            "produtos_updated": 0,
            "imagens_created": 0,
            "errors": []
        }
        
        # Limpa todos os dados se solicitado
        deleted_summary = {}
        if clean_before:
            logger.info("Modo PUT: Limpando todos os dados antes de processar")
            deleted_summary = self._clean_all_data(session)
            summary["deleted_summary"] = deleted_summary

        try:
            # Lê e valida a planilha
            df = self.loader.read(file_path)
            
            # Detecta formato pelas colunas (CSV e Excel novo têm mesma estrutura)
            has_csv_cols = all(col in df.columns for col in ['codigo', 'Nome'])
            has_old_excel_cols = all(col in df.columns for col in ['PRODUTO', 'CATEGORIA'])
            
            # Se tiver colunas do novo formato (CSV), usa processamento CSV mesmo que seja Excel
            if has_csv_cols:
                detected_format = 'csv'
            elif has_old_excel_cols:
                detected_format = 'excel'
            else:
                # Default para CSV se não conseguir detectar
                detected_format = 'csv'
                logger.warning(f"Formato não identificado claramente, usando processamento CSV. Colunas: {list(df.columns)}")
            
            self.loader.validate_columns(df, detected_format)
            
            # Extrai dados (kits_map não é mais necessário, kits são campos do Product)
            produtos_data, _ = self.loader.extract_entities(df, detected_format)
            
            if not produtos_data:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Nenhum produto válido encontrado na planilha"
                )

            # Dicionários para evitar duplicatas no mesmo run
            seen_categorias = {}
            seen_subcategorias = {}
            seen_produtos = {}  # Para CSV: mapeia código -> produto

            # Inicia transação
            try:
                logger.info(f"Iniciando processamento de {len(produtos_data)} produto(s)")
                if detected_format == 'csv':
                    self._process_csv_format(
                        produtos_data, session, summary,
                        seen_categorias, seen_subcategorias, seen_produtos
                    )
                else:
                    self._process_excel_format(
                        produtos_data, session, summary,
                        seen_categorias, seen_subcategorias
                    )
                
                logger.info(f"Processamento concluído. Resumo: {summary}")
                
            except Exception as e:
                session.rollback()
                logger.exception("Erro no processamento, rollback realizado")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Erro no processamento: {str(e)}"
                )

        except HTTPException:
            raise
        except Exception as e:
            logger.exception("Erro no upload em massa")
            if session:
                session.rollback()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao processar planilha: {str(e)}"
            )

        # Gera planilha atualizada com URLs do Supabase e faz upload
        excel_url = None
        try:
            logger.info("Gerando planilha atualizada com URLs do Supabase")
            excel_url = self._generate_updated_excel(file_path, df, detected_format, session)
            if excel_url:
                logger.info(f"Planilha atualizada salva no Supabase: {excel_url}")
        except Exception as e:
            logger.error(f"Erro ao gerar planilha atualizada: {e}", exc_info=True)
            # Não falha o processo se houver erro na geração da planilha

        return {
            "success": True,
            "message": "Upload realizado com sucesso",
            "summary": summary,
            "excel_url": excel_url
        }

    def _process_csv_format(
        self, produtos_data, session, summary,
        seen_categorias, seen_subcategorias, seen_produtos
    ):
        """Processa formato CSV"""
        for idx, p in enumerate(produtos_data):
            try:
                # Busca categoria por ID
                categoria = None
                id_categoria = p.get('id_categoria')
                if id_categoria:
                    if id_categoria not in seen_categorias:
                        categoria = self.category_repository.get_by_id(id_categoria, session)
                        if not categoria:
                            summary["errors"].append({
                                "row": idx + 2,
                                "type": "produto",
                                "codigo": p.get('codigo', 'N/A'),
                                "error": f"Categoria com ID {id_categoria} não encontrada"
                            })
                            continue
                        seen_categorias[id_categoria] = categoria
                    else:
                        categoria = seen_categorias[id_categoria]
                else:
                    summary["errors"].append({
                        "row": idx + 2,
                        "type": "produto",
                        "codigo": p.get('codigo', 'N/A'),
                        "error": "ID da categoria não informado"
                    })
                    continue

                # Busca subcategoria por ID (opcional)
                sub = None
                id_subcategoria = p.get('id_subcategoria')
                if id_subcategoria:
                    sub_key = f"{id_categoria}::{id_subcategoria}"
                    if sub_key not in seen_subcategorias:
                        sub = self.subcategory_repository.get_by_id(id_subcategoria, session)
                        if not sub or sub.id_categoria != id_categoria:
                            summary["errors"].append({
                                "row": idx + 2,
                                "type": "produto",
                                "codigo": p.get('codigo', 'N/A'),
                                "error": f"Subcategoria com ID {id_subcategoria} não encontrada ou não pertence à categoria {id_categoria}"
                            })
                            continue
                        seen_subcategorias[sub_key] = sub
                    else:
                        sub = seen_subcategorias[sub_key]

                # Busca ou cria produto por código
                codigo = p.get('codigo', '').strip()
                nome = p.get('nome', '').strip()
                if not codigo and not nome:
                    continue

                existing_product = None
                if codigo:
                    existing_product = self.product_repository.get_by_codigo(codigo, session)
                    seen_produtos[codigo] = existing_product

                if existing_product:
                    # Atualiza produto existente
                    updated = False
                    if p.get('descricao') and existing_product.descricao != p.get('descricao'):
                        existing_product.descricao = p.get('descricao')
                        updated = True
                    if p.get('valor_base') is not None and existing_product.valor_base != p.get('valor_base'):
                        existing_product.valor_base = p.get('valor_base')
                        updated = True
                    if categoria and existing_product.id_categoria != categoria.id_categoria:
                        existing_product.id_categoria = categoria.id_categoria
                        updated = True
                    if sub and existing_product.id_subcategoria != sub.id_subcategoria:
                        existing_product.id_subcategoria = sub.id_subcategoria
                        updated = True
                    
                    # Atualiza quantidade e cod_kit
                    quantidade = p.get('quantidade', 1)
                    if existing_product.quantidade != quantidade:
                        existing_product.quantidade = quantidade
                        updated = True
                    
                    codigo_amarracao = p.get('codigo_amarracao')
                    # cod_kit agora é string (mesmo tipo do codigo)
                    cod_kit = codigo_amarracao if codigo_amarracao else None
                    logger.debug(f"Produto {codigo}: codigo_amarracao={codigo_amarracao} -> cod_kit={cod_kit}")
                    
                    # Compara considerando None
                    current_cod_kit = existing_product.cod_kit if existing_product.cod_kit is not None else None
                    new_cod_kit = cod_kit if cod_kit is not None else None
                    
                    if current_cod_kit != new_cod_kit:
                        existing_product.cod_kit = cod_kit
                        updated = True
                        logger.debug(f"Atualizando cod_kit do produto {codigo}: {current_cod_kit} -> {new_cod_kit}")
                    
                    if updated:
                        self.product_repository.update(existing_product, session)
                        summary["produtos_updated"] += 1
                    produto = existing_product
                    
                    # Processa imagens do produto (atualiza/remove/adiciona)
                    self._process_product_images(produto, p.get('image_urls', []), session, summary)
                else:
                    # Cria novo produto
                    if not codigo:
                        codigo = f"PROD-{nome[:20].upper().replace(' ', '-')}"
                        counter = 1
                        original_codigo = codigo
                        while self.product_repository.get_by_codigo(codigo, session):
                            codigo = f"{original_codigo}-{counter}"
                            counter += 1
                    
                    # cod_kit agora é string (mesmo tipo do codigo)
                    codigo_amarracao = p.get('codigo_amarracao')
                    cod_kit = codigo_amarracao if codigo_amarracao else None
                    logger.debug(f"Criando produto {codigo}: codigo_amarracao={codigo_amarracao} -> cod_kit={cod_kit}")
                    
                    # Obtém quantidade
                    quantidade = p.get('quantidade', 1)
                    
                    produto = Product(
                        codigo=codigo,
                        nome=nome,
                        descricao=p.get('descricao'),
                        id_categoria=categoria.id_categoria if categoria else None,
                        id_subcategoria=sub.id_subcategoria if sub else None,
                        valor_base=p.get('valor_base') or 0,
                        quantidade=quantidade,
                        cod_kit=cod_kit,
                        ativo=True
                    )
                    produto = self.product_repository.create(produto, session)
                    seen_produtos[codigo] = produto
                    summary["produtos_created"] += 1
                    
                    # Processa imagens do produto
                    self._process_product_images(produto, p.get('image_urls', []), session, summary)

            except Exception as e:
                summary["errors"].append({
                    "row": idx + 2,
                    "type": "produto",
                    "codigo": p.get('codigo', 'N/A'),
                    "error": str(e)
                })
                logger.warning(f"Erro ao processar linha {idx+2}: {e}")

    def _process_product_images(self, produto: Product, image_urls: List[str], session: Session, summary: Dict[str, Any]):
        """
        Processa as imagens do produto:
        1. Faz download das imagens do Google Drive
        2. Faz upload para Supabase Storage
        3. Salva a URL do Supabase no banco de dados
        Cada URL do array cria um objeto novo na tabela imagens_produto.
        """
        if not image_urls:
            logger.debug(f"Produto {produto.codigo} sem imagens para processar")
            return
        
        try:
            logger.info(f"🖼️  Processando {len(image_urls)} URL(s) de imagem para o produto {produto.codigo} (ID: {produto.id_produto})")
            
            # Verifica se o SupabaseService está inicializado
            if not hasattr(self, 'supabase_service') or self.supabase_service is None:
                logger.error(f"❌ SupabaseService não está inicializado para produto {produto.codigo}")
                summary["errors"].append({
                    "type": "imagem",
                    "product_codigo": produto.codigo,
                    "error": "SupabaseService não está inicializado"
                })
                return
            
            # Busca imagens existentes do produto usando o repository
            existing_images = self.product_image_repository.get_by_produto(produto.id_produto, session)
            
            # Remove duplicatas mantendo a ordem (para logs consistentes)
            unique_urls = list(dict.fromkeys(image_urls))
            
            logger.debug(f"Produto {produto.codigo}: {len(existing_images)} imagem(ns) existente(s), {len(unique_urls)} URL(s) para processar")
            
            # Remove imagens que não estão mais na lista usando o repository
            # Como agora salvamos URLs do Supabase, precisamos verificar se a URL do Drive corresponde
            # Para isso, vamos processar todas as novas URLs e depois remover as que não foram processadas
            processed_supabase_urls = set()
            
            # Adiciona novas imagens - Processa cada URL do Google Drive e faz upload para Supabase
            created_count = 0
            for idx, drive_url in enumerate(unique_urls, start=1):
                drive_url_clean = drive_url.strip()
                
                # Valida URL básica
                if not drive_url_clean:
                    logger.warning(f"URL vazia ignorada na posição {idx} para produto {produto.codigo}")
                    continue
                
                if not (drive_url_clean.startswith('http://') or drive_url_clean.startswith('https://')):
                    logger.warning(f"URL de imagem inválida para produto {produto.codigo} (posição {idx}): {drive_url_clean[:80]}...")
                    continue
                
                # Verifica se já existe uma imagem com esta URL do Drive processada anteriormente
                # Como salvamos URLs do Supabase no banco, não podemos comparar diretamente
                # Vamos processar todas as URLs e o banco evitará duplicatas por URL única
                
                try:
                    # Converte link do Google Drive para formato de download
                    download_url = self.drive_service.convert_drive_link(drive_url_clean)
                    if not download_url:
                        logger.error(f"Produto {produto.codigo}, Imagem {idx}: Não foi possível converter o link do Google Drive")
                        summary["errors"].append({
                            "type": "imagem",
                            "product_codigo": produto.codigo,
                            "error": f"Não foi possível converter link do Google Drive: {drive_url_clean[:50]}..."
                        })
                        continue
                    
                    # Verifica se a URL já é do Supabase
                    is_supabase_url = 'supabase.co' in download_url or 'supabase' in download_url.lower()
                    
                    if is_supabase_url:
                        # CAMINHO 5: URL já é do Supabase - apenas valida existência
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: URL já é do Supabase, validando existência no Storage")
                        supabase_url = download_url
                        
                        # CAMINHO 1: Verifica se o arquivo realmente existe no Storage
                        try:
                            # A URL do Supabase tem formato: https://.../storage/v1/object/public/bucket/path
                            # Extrai o path após o bucket
                            if f"/{self.supabase_service.bucket}/" in supabase_url:
                                path = supabase_url.split(f"/{self.supabase_service.bucket}/")[-1]
                                if not self.supabase_service.file_exists(path):
                                    logger.error(f"Produto {produto.codigo}, Imagem {idx}: ❌ URL do Supabase mas arquivo não existe no Storage!")
                                    logger.error(f"CAMINHO 1: Storage é fonte única - arquivo não existe, não registrando no banco")
                                    summary["errors"].append({
                                        "type": "imagem",
                                        "product_codigo": produto.codigo,
                                        "error": f"URL do Supabase mas arquivo não encontrado no Storage"
                                    })
                                    continue
                                else:
                                    logger.info(f"Produto {produto.codigo}, Imagem {idx}: ✅ Arquivo confirmado no Storage")
                        except Exception as verify_error:
                            logger.warning(f"Produto {produto.codigo}, Imagem {idx}: Não foi possível verificar existência no Storage: {verify_error}")
                            # Continua mesmo assim, pois a URL é do Supabase
                    else:
                        # CAMINHO 5: Faz download da imagem do Google Drive e upload para Supabase
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: Fazendo download do Google Drive")
                        image_bytes = self.drive_service.download_image(download_url)
                        if not image_bytes:
                            logger.error(f"Produto {produto.codigo}, Imagem {idx}: Falha no download da imagem")
                            summary["errors"].append({
                                "type": "imagem",
                                "product_codigo": produto.codigo,
                                "error": f"Falha no download da imagem: {download_url[:50]}..."
                            })
                            continue
                        
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: Download concluído ({len(image_bytes)} bytes)")
                        
                        # Define nome do arquivo no Supabase
                        if len(unique_urls) == 1:
                            file_name = f"{produto.codigo}.jpg"
                        else:
                            file_name = f"{produto.codigo}_{idx}.jpg"
                        
                        # CAMINHO 2: Faz upload para o Supabase Storage
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: Fazendo upload para Supabase Storage")
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: Tamanho do arquivo: {len(image_bytes)} bytes")
                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: Nome do arquivo: {file_name}")
                        
                        try:
                            supabase_url = self.supabase_service.upload_image(
                                file_name=file_name,
                                file_bytes=image_bytes,
                                content_type="image/jpeg"
                            )
                            
                            if not supabase_url:
                                logger.error(f"Produto {produto.codigo}, Imagem {idx}: ❌ Upload retornou None - Não foi possível fazer upload no Supabase")
                                logger.error(f"CAMINHO 6: Upload falhou - não registrando URL no banco")
                                summary["errors"].append({
                                    "type": "imagem",
                                    "product_codigo": produto.codigo,
                                    "error": f"Falha no upload para Supabase (retornou None)"
                                })
                                continue
                            
                            # CAMINHO 6: Valida que a URL foi realmente criada no Storage
                            logger.info(f"Produto {produto.codigo}, Imagem {idx}: ✅ Upload concluído com sucesso: {supabase_url[:80]}...")
                            
                            # CAMINHO 1: Verifica se o arquivo realmente existe no Storage antes de registrar
                            try:
                                # A URL do Supabase tem formato: https://.../storage/v1/object/public/bucket/path
                                # Extrai o path após o bucket
                                if f"/{self.supabase_service.bucket}/" in supabase_url:
                                    path = supabase_url.split(f"/{self.supabase_service.bucket}/")[-1]
                                    if not self.supabase_service.file_exists(path):
                                        logger.error(f"Produto {produto.codigo}, Imagem {idx}: ❌ Arquivo não encontrado no Storage após upload!")
                                        logger.error(f"CAMINHO 1: Storage é fonte única - arquivo não existe, não registrando no banco")
                                        summary["errors"].append({
                                            "type": "imagem",
                                            "product_codigo": produto.codigo,
                                            "error": f"Arquivo não encontrado no Storage após upload"
                                        })
                                        continue
                                    else:
                                        logger.info(f"Produto {produto.codigo}, Imagem {idx}: ✅ Arquivo confirmado no Storage")
                            except Exception as verify_error:
                                logger.warning(f"Produto {produto.codigo}, Imagem {idx}: Não foi possível verificar existência no Storage: {verify_error}")
                                # Continua mesmo assim, pois o upload retornou URL válida
                        except Exception as upload_error:
                            logger.error(f"Produto {produto.codigo}, Imagem {idx}: ❌ Exceção durante upload: {upload_error}", exc_info=True)
                            summary["errors"].append({
                                "type": "imagem",
                                "product_codigo": produto.codigo,
                                "error": f"Exceção no upload: {str(upload_error)}"
                            })
                            continue
                    
                    # CAMINHO 6: Ordem correta - Upload feito, arquivo existe, agora registra no banco
                    # Verifica se já existe esta URL do Supabase no banco
                    existing_image = self.product_image_repository.get_by_url(supabase_url, session)
                    if existing_image and existing_image.id_produto == produto.id_produto:
                        logger.debug(f"URL do Supabase já existe para produto {produto.codigo}, ignorando: {supabase_url[:80]}...")
                        processed_supabase_urls.add(supabase_url)
                        continue
                    
                    # CAMINHO 4: Registra URL no banco (tabela imagens_produto é o ponto único)
                    # CAMINHO 1: Só registra URLs que existem no Storage (já validado acima)
                    product_image = ProductImage(
                        id_produto=produto.id_produto,
                        url=supabase_url  # CAMINHO 1: URL que existe no Storage (fonte única)
                    )
                    created_image = self.product_image_repository.create(product_image, session)
                    created_count += 1
                    summary["imagens_created"] += 1
                    processed_supabase_urls.add(supabase_url)
                    
                    logger.info(f"✅ CAMINHO 6: Registrado no banco - ProductImage ID {created_image.id_imagem} para produto {produto.codigo}")
                    logger.info(f"   URL: {supabase_url[:80]}...")
                    
                except Exception as e:
                    logger.error(f"Erro ao processar imagem {idx} do produto {produto.codigo}: {e}", exc_info=True)
                    summary["errors"].append({
                        "type": "imagem",
                        "product_codigo": produto.codigo,
                        "error": f"Erro ao processar imagem {idx}: {str(e)}"
                    })
                    continue
            
            # Remove imagens que não estão mais na lista (URLs do Supabase que não foram processadas)
            for img in existing_images:
                if img.url not in processed_supabase_urls:
                    self.product_image_repository.delete(img.id_imagem, session)
                    logger.debug(f"Removendo imagem ID {img.id_imagem} (URL: '{img.url[:80]}...') do produto {produto.codigo}")
            
            logger.info(f"Produto {produto.codigo}: {created_count} nova(s) imagem(ns) criada(s) em imagens_produto")
                        
        except Exception as e:
            logger.error(f"Erro ao processar imagens do produto {produto.codigo}: {e}", exc_info=True)
            summary["errors"].append({
                "type": "imagem",
                "product_codigo": produto.codigo,
                "error": str(e)
            })

    def _clean_all_data(self, session: Session) -> Dict[str, int]:
        """
        Limpa todos os dados de produtos e imagens do banco e Supabase
        
        Args:
            session: Sessão do banco de dados
            
        Returns:
            Dicionário com contadores do que foi deletado
        """
        deleted_counts = {
            "produtos_deletados": 0,
            "imagens_deletados": 0,
            "imagens_supabase_deletadas": 0
        }
        
        try:
            logger.info("Iniciando limpeza de todos os dados de produtos")
            
            # 1. Busca todas as imagens para obter URLs do Supabase antes de deletar
            all_images = self.product_image_repository.get_all(session, skip=0, limit=100000)
            deleted_counts["imagens_deletados"] = len(all_images)
            
            logger.info(f"Encontradas {len(all_images)} imagem(ns) no banco de dados")
            
            # 2. Deleta todas as imagens do banco
            for img in all_images:
                self.product_image_repository.delete(img.id_imagem, session)
            
            logger.info(f"Deletadas {len(all_images)} imagem(ns) do banco de dados")
            
            # 3. Deleta todas as imagens do Supabase Storage (pasta produtos/)
            logger.info("Deletando todas as imagens do Supabase Storage (pasta produtos/)")
            try:
                success = self.supabase_service.delete_all_images_in_folder("produtos")
                if success:
                    deleted_counts["imagens_supabase_deletadas"] = len(all_images)  # Aproximação
                    logger.info("Imagens do Supabase deletadas com sucesso")
                else:
                    logger.warning("Alguns arquivos do Supabase podem não ter sido deletados")
            except Exception as e:
                logger.error(f"Erro ao deletar imagens do Supabase: {e}", exc_info=True)
            
            # 4. Deleta todos os produtos do banco
            all_products = self.product_repository.get_all(session, skip=0, limit=100000)
            deleted_counts["produtos_deletados"] = len(all_products)
            
            logger.info(f"Encontrados {len(all_products)} produto(s) no banco de dados")
            
            for product in all_products:
                self.product_repository.delete(product.id_produto, session)
            
            logger.info(f"Deletados {len(all_products)} produto(s) do banco de dados")
            
            session.flush()
            
            logger.info(f"Limpeza concluída: {deleted_counts}")
            return deleted_counts
            
        except Exception as e:
            logger.error(f"Erro ao limpar dados: {e}", exc_info=True)
            raise

    def _generate_updated_excel(self, file_path: str, df_original: pd.DataFrame, format_type: str, session: Session) -> Optional[str]:
        """
        Gera planilha atualizada com URLs do Supabase e faz upload no Supabase Storage
        
        Args:
            file_path: Caminho do arquivo original
            df_original: DataFrame original da planilha
            format_type: Tipo de formato ('csv' ou 'excel')
            session: Sessão do banco de dados
            
        Returns:
            URL do Excel no Supabase ou None em caso de erro
        """
        try:
            logger.info("Iniciando geração de planilha atualizada com URLs do Supabase")
            
            # Cria cópia do DataFrame para modificar
            df_updated = df_original.copy()
            
            # Adiciona coluna imagem_supabase se não existir
            if 'imagem_supabase' not in df_updated.columns:
                df_updated['imagem_supabase'] = ''
            
            # Identifica coluna de código do produto
            codigo_col = None
            for col in ['codigo', 'Codigo', 'CODIGO', 'PRODUTO']:
                if col in df_updated.columns:
                    codigo_col = col
                    break
            
            if not codigo_col:
                logger.warning("Coluna de código não encontrada, não é possível atualizar URLs")
                return None
            
            # CAMINHO 3: Cursor NUNCA gera URL - apenas lê URLs que existem no banco
            # CAMINHO 1: Banco só referencia URLs que existem no Storage
            for index, row in df_updated.iterrows():
                try:
                    codigo = str(row[codigo_col]).strip()
                    if not codigo or codigo.lower() in ['nan', 'none', '']:
                        continue
                    
                    # Busca produto no banco
                    produto = self.product_repository.get_by_codigo(codigo, session)
                    if not produto:
                        # CAMINHO 3: Produto não existe? Ignora (não gera URL)
                        continue
                    
                    # CAMINHO 4: Busca imagens do produto no banco (ponto único de registro)
                    # CAMINHO 1: Essas URLs já foram validadas - existem no Storage
                    imagens = self.product_image_repository.get_by_produto(produto.id_produto, session)
                    if imagens:
                        # CAMINHO 3: Apenas copia URLs existentes - NUNCA constrói URL
                        supabase_urls = [img.url for img in imagens]
                        supabase_urls_str = '[' + ', '.join(supabase_urls) + ']'
                        df_updated.at[index, 'imagem_supabase'] = supabase_urls_str
                        logger.debug(f"✅ CAMINHO 3: Produto {codigo}: {len(supabase_urls)} URL(s) real(is) copiada(s) do banco")
                    else:
                        # CAMINHO 3: Sem imagem? Deixa vazio (não gera URL padrão)
                        df_updated.at[index, 'imagem_supabase'] = ''
                        logger.debug(f"Produto {codigo}: Sem imagens no banco - deixando vazio (não gerando URL)")
                    
                except Exception as e:
                    logger.warning(f"Erro ao atualizar linha {index + 1}: {e}")
                    continue
            
            # Gera novo arquivo Excel em memória
            output = io.BytesIO()
            with pd.ExcelWriter(output, engine='openpyxl') as writer:
                df_updated.to_excel(writer, index=False, sheet_name='Produtos')
            
            output.seek(0)
            result_bytes = output.read()
            
            logger.info(f"Arquivo Excel gerado: {len(result_bytes)} bytes")
            
            # Faz upload do Excel para o Supabase
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            excel_file_name = f"produtos_atualizados_{timestamp}.xlsx"
            
            logger.info(f"Fazendo upload do Excel atualizado para Supabase: {excel_file_name}")
            excel_url = self.supabase_service.upload_file(
                file_name=excel_file_name,
                file_bytes=result_bytes,
                content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
            
            return excel_url
            
        except Exception as e:
            logger.error(f"Erro ao gerar planilha atualizada: {e}", exc_info=True)
            return None

    def _process_excel_format(
        self, produtos_data, session, summary,
        seen_categorias, seen_subcategorias
    ):
        """Processa formato Excel (método original) - TODO: Implementar se necessário"""
        # Processa produtos
        for idx, p in enumerate(produtos_data):
            try:
                # Category
                categoria = None
                cat_key = p.get('categoria', '').strip()
                if not cat_key:
                    summary["errors"].append({
                        "row": idx + 2,
                        "type": "produto",
                        "nome": p.get('nome', 'N/A'),
                        "error": "Category não informada"
                    })
                    continue
                
                if cat_key:
                    if cat_key not in seen_categorias:
                        # Tenta buscar existente
                        categoria = self.category_repository.get_by_name(cat_key, session)
                        if not categoria:
                            # Cria nova
                            from app.domain.models.category_model import Category
                            categoria = Category(nome=cat_key)
                            categoria = self.category_repository.create(categoria, session)
                            summary["categorias_created"] += 1
                        seen_categorias[cat_key] = categoria
                    else:
                        categoria = seen_categorias[cat_key]

                # Subcategory
                sub = None
                sub_key = p.get('subcategoria', '').strip()
                if sub_key and categoria:
                    sc_key = f"{cat_key}::{sub_key}"
                    if sc_key not in seen_subcategorias:
                        # Busca existente (por nome e categoria)
                        sub = self.subcategory_repository.get_by_name(sub_key, session)
                        if sub and sub.id_categoria != categoria.id_categoria:
                            # Nome existe mas para outra categoria, cria novo
                            sub = None
                        if not sub:
                            # Cria nova
                            from app.domain.models.subcategory_model import Subcategory
                            sub = Subcategory(nome=sub_key, id_categoria=categoria.id_categoria)
                            sub = self.subcategory_repository.create(sub, session)
                            summary["subcategorias_created"] += 1
                        seen_subcategorias[sc_key] = sub
                    else:
                        sub = seen_subcategorias[sc_key]

                # Product - busca por nome exato
                product_nome = p.get('nome', '').strip()
                product_code = p.get('codigo', '').strip()
                if not product_code:
                    continue
                    
                existing_product = self.product_repository.get_by_codigo(product_code, session)
                
                if existing_product:
                    # Atualiza produto existente
                    updated = False
                    if p.get('descricao') and existing_product.descricao != p.get('descricao'):
                        existing_product.descricao = p.get('descricao')
                        updated = True
                    if p.get('valor_base') is not None and existing_product.valor_base != p.get('valor_base'):
                        existing_product.valor_base = p.get('valor_base')
                        updated = True
                    if categoria and existing_product.id_categoria != categoria.id_categoria:
                        existing_product.id_categoria = categoria.id_categoria
                        updated = True
                    if sub and existing_product.id_subcategoria != sub.id_subcategoria:
                        existing_product.id_subcategoria = sub.id_subcategoria
                        updated = True
                    if updated:
                        self.product_repository.update(existing_product, session)
                        summary["produtos_updated"] += 1
                else:
                    produto = Product(
                        codigo=product_code,
                        nome=product_nome,
                        descricao=p.get('descricao'),
                        id_categoria=categoria.id_categoria if categoria else None,
                        id_subcategoria=sub.id_subcategoria if sub else None,
                        valor_base=p.get('valor_base') or 0,
                        quantidade=1,  # Excel antigo não tem quantidade
                        cod_kit=None,  # Excel antigo não tem código amarração
                        ativo=True
                    )
                    self.product_repository.create(produto, session)
                    summary["produtos_created"] += 1

            except Exception as e:
                summary["errors"].append({
                    "row": idx + 2,
                    "type": "produto",
                    "nome": p.get('nome', 'N/A'),
                    "error": str(e)
                })
