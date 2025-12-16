"""Use case para upload completo de planilha CSV ou Excel com kits, regiões, prazos e produtos"""

import io
import datetime
import hashlib
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

        # Cache global do run: evita download/upload repetidos dentro do mesmo job
        # key -> supabase_public_url
        self._shared_image_cache: Dict[str, str] = {}

    def _is_supabase_public_url(self, url: str) -> bool:
        if not url:
            return False
        u = url.lower()
        return "/storage/v1/object/public/" in u and ".supabase.co" in u

    def _image_key(self, original_url: str, download_url: str) -> str:
        """
        Chave global da imagem para dedupe:
        - Preferencial: drive file_id (mesmo arquivo, links diferentes)
        - Fallback: hash da URL (sha1)
        """
        file_id = self.drive_service.extract_drive_file_id(original_url) or self.drive_service.extract_drive_file_id(download_url)
        if file_id:
            return f"drive_{file_id}"
        base = (download_url or original_url or "").strip()
        h = hashlib.sha1(base.encode("utf-8")).hexdigest()
        return f"url_{h}"

    def _shared_object_path(self, key: str) -> str:
        # Mantém path determinístico para reaproveitar entre produtos/runs.
        return f"produtos/shared/{key}.jpg"

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

        # Gera planilha atualizada com URLs locais das imagens
        excel_url = None
        try:
            logger.info("Gerando planilha atualizada com URLs locais das imagens")
            excel_url = self._generate_updated_excel(file_path, df, detected_format, session)
            if excel_url:
                logger.info(f"Planilha atualizada gerada: {excel_url}")
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
        1. Deduplica URLs (por produto) mantendo ordem
        2. Deduplica GLOBALMENTE (por job e por histórico no banco) usando chave baseada em Drive file_id (fallback hash)
        3. Faz download (Drive) e upload (Supabase) apenas 1x por imagem única
        4. Salva a URL pública do Supabase no banco de dados (imagens_produto.url)
        Cada URL do array cria um objeto novo na tabela imagens_produto.
        REGRA: Imagens repetidas (mesmo arquivo do Drive) reaproveitam o mesmo objeto no Storage.
        """
        unique_urls = list(dict.fromkeys([str(u).strip() for u in (image_urls or []) if u and str(u).strip()]))
        if not unique_urls:
            return

        existing_images = self.product_image_repository.get_by_produto(produto.id_produto, session)
        processed_urls: set[str] = set()
        created_count = 0

        logger.info(f"[IMG] produto={produto.codigo} unique_urls={len(unique_urls)}")

        for idx, original_url in enumerate(unique_urls, start=1):
            try:
                if not (original_url.startswith("http://") or original_url.startswith("https://")):
                    logger.warning(f"[IMG] produto={produto.codigo} idx={idx} invalid_url={original_url[:120]}")
                    continue

                download_url = self.drive_service.convert_drive_link(original_url)
                if not download_url:
                    summary["errors"].append({
                        "type": "imagem",
                        "product_codigo": produto.codigo,
                        "error": f"Não foi possível converter link do Drive: {original_url[:120]}"
                    })
                    logger.error(f"[IMG] produto={produto.codigo} idx={idx} convert_failed url={original_url[:120]}")
                    continue

                # Caso já seja URL pública do Supabase: não faz download/upload
                if self._is_supabase_public_url(download_url):
                    supabase_url = download_url
                    source = "supabase_input"
                else:
                    key = self._image_key(original_url=original_url, download_url=download_url)

                    cached_url = self._shared_image_cache.get(key)
                    if cached_url:
                        supabase_url = cached_url
                        source = "cache_hit"
                    else:
                        object_path = self._shared_object_path(key)
                        supabase_url = self.supabase_service.public_url_for_path(object_path)

                        # Dedupe global por histórico no DB: se já existe essa URL em qualquer produto, reutiliza.
                        existing_any = self.product_image_repository.get_by_url(supabase_url, session)
                        if existing_any:
                            self._shared_image_cache[key] = supabase_url
                            source = "db_hit"
                        else:
                            image_bytes, content_type = self.drive_service.download_image_with_meta(download_url, timeout=30)
                            if not image_bytes:
                                summary["errors"].append({
                                    "type": "imagem",
                                    "product_codigo": produto.codigo,
                                    "error": f"Falha no download: {download_url[:120]}"
                                })
                                logger.error(f"[IMG] produto={produto.codigo} idx={idx} download_failed url={download_url[:120]}")
                                continue

                            content_type = content_type or "image/jpeg"
                            uploaded_url = self.supabase_service.upload_image(
                                file_name=object_path,
                                file_bytes=image_bytes,
                                content_type=content_type
                            )
                            if not uploaded_url:
                                summary["errors"].append({
                                    "type": "imagem",
                                    "product_codigo": produto.codigo,
                                    "error": "Falha no upload para Supabase (retornou None)"
                                })
                                logger.error(f"[IMG] produto={produto.codigo} idx={idx} upload_failed key={key}")
                                continue

                            supabase_url = uploaded_url
                            self._shared_image_cache[key] = supabase_url
                            source = "uploaded"

                # Registra para este produto (evita duplicata por produto)
                if self.product_image_repository.exists_by_url(supabase_url, produto.id_produto, session):
                    processed_urls.add(supabase_url)
                    logger.debug(f"[IMG] produto={produto.codigo} idx={idx} db_skip=exists source={source}")
                    continue

                created = self.product_image_repository.create(
                    ProductImage(id_produto=produto.id_produto, url=supabase_url),
                    session
                )
                created_count += 1
                summary["imagens_created"] += 1
                processed_urls.add(supabase_url)
                logger.info(f"[IMG] produto={produto.codigo} idx={idx} db_created=1 id_imagem={created.id_imagem} source={source}")

            except Exception as e:
                logger.error(f"[IMG] produto={produto.codigo} idx={idx} exception={e}", exc_info=True)
                summary["errors"].append({
                    "type": "imagem",
                    "product_codigo": produto.codigo,
                    "error": f"Erro ao processar imagem {idx}: {str(e)}"
                })

        # Remove imagens que não estão mais na lista do produto
        for img in existing_images:
            if img.url not in processed_urls:
                self.product_image_repository.delete(img.id_imagem, session)
                logger.info(f"[IMG] produto={produto.codigo} db_deleted=1 id_imagem={img.id_imagem}")

        logger.info(f"[IMG] produto={produto.codigo} created={created_count} processed={len(processed_urls)} cache_size={len(self._shared_image_cache)}")

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
            
            # 1. Busca todas as imagens antes de deletar
            all_images = self.product_image_repository.get_all(session, skip=0, limit=100000)
            deleted_counts["imagens_deletados"] = len(all_images)
            
            logger.info(f"Encontradas {len(all_images)} imagem(ns) no banco de dados")
            
            # 2. Deleta todas as imagens do banco
            for img in all_images:
                self.product_image_repository.delete(img.id_imagem, session)
            
            logger.info(f"Deletadas {len(all_images)} imagem(ns) do banco de dados")
            
            # 3. Deleta imagens no Supabase Storage (pasta produtos/ e subpastas, incluindo shared/)
            logger.info("Deletando todas as imagens do Supabase Storage (pasta produtos/)")
            try:
                # Tenta primeiro a subpasta shared (em alguns casos list() não lista recursivamente)
                try:
                    self.supabase_service.delete_all_images_in_folder("produtos/shared")
                except Exception:
                    pass

                success = self.supabase_service.delete_all_images_in_folder("produtos")
                if success:
                    deleted_counts["imagens_supabase_deletadas"] = len(all_images)  # aproximação
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
        Gera planilha atualizada com URLs locais das imagens
        
        Args:
            file_path: Caminho do arquivo original
            df_original: DataFrame original da planilha
            format_type: Tipo de formato ('csv' ou 'excel')
            session: Sessão do banco de dados
            
        Returns:
            Caminho do arquivo Excel atualizado ou None em caso de erro
        """
        try:
            logger.info("Iniciando geração de planilha atualizada com URLs locais das imagens")
            
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
                    
                    # Busca imagens do produto no banco (URLs locais)
                    imagens = self.product_image_repository.get_by_produto(produto.id_produto, session)
                    if imagens:
                        # Copia URLs locais existentes do banco
                        image_urls = [img.url for img in imagens]
                        image_urls_str = '[' + ', '.join(image_urls) + ']'
                        df_updated.at[index, 'imagem_supabase'] = image_urls_str
                        logger.debug(f"✅ Produto {codigo}: {len(image_urls)} URL(s) local(is) copiada(s) do banco")
                    else:
                        # Sem imagem? Deixa vazio
                        df_updated.at[index, 'imagem_supabase'] = ''
                        logger.debug(f"Produto {codigo}: Sem imagens no banco - deixando vazio")
                    
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
            
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            excel_file_name = f"produtos_atualizados_{timestamp}.xlsx"

            # Faz upload do Excel para o Supabase (pasta planilhas/)
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
