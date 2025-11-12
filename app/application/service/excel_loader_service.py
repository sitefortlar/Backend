"""Serviço para processamento completo de planilhas CSV e Excel com kits, regiões e prazos"""

import pandas as pd
from decimal import Decimal
from typing import Dict, Any, List, Tuple, Optional
import logging
import re

logger = logging.getLogger(__name__)

# Colunas obrigatórias para formato Excel antigo
REQUIRED_COLUMNS_EXCEL = [
    'PRODUTO', 'CATEGORIA', 'SUBCATEGORIA', 'DESCRIÇÃO',
    'REGIÃO', 'PRAZO DE ENTREGA', 'VALOR UNITÁRIO', 'KIT', 'OBSERVAÇÕES'
]

# Colunas obrigatórias para formato CSV novo
REQUIRED_COLUMNS_CSV = [
    'codigo', 'id_categoria', 'id_subcategoria', 'Nome', 
    'Quantidade', 'Descricao', 'Vlr Bruto', 'Vlr Unitario'
]
# Colunas opcionais
OPTIONAL_COLUMNS_CSV = [
    'image_url', 'image_urls', 'imagem_url', 'imagens_url'
]


class ExcelLoaderService:
    """
    Lê planilhas CSV ou Excel e transforma em estrutura pronta para persistência.
    Detecta kits e processa preços por região/prazo.
    """

    def __init__(self, sheet_name: str = None, file_format: str = 'auto'):
        self.sheet_name = sheet_name
        self.file_format = file_format  # 'auto', 'csv', 'excel'

    def _detect_format(self, file_path: str) -> str:
        """Detecta o formato do arquivo"""
        if self.file_format != 'auto':
            return self.file_format
        
        if file_path.lower().endswith('.csv'):
            return 'csv'
        return 'excel'

    def read(self, file_path: str) -> pd.DataFrame:
        """Lê arquivo CSV ou Excel e normaliza nomes das colunas"""
        file_format = self._detect_format(file_path)
        
        try:
            if file_format == 'csv':
                # Lê CSV com encoding UTF-8 e separador vírgula
                df = pd.read_csv(
                    file_path, 
                    encoding='utf-8',
                    sep=',',
                    quotechar='"',
                    skipinitialspace=True
                )
            else:
                # Lê Excel - trata múltiplas abas
                excel_data = pd.read_excel(file_path, sheet_name=self.sheet_name)
                
                if isinstance(excel_data, dict):
                    if self.sheet_name:
                        if self.sheet_name in excel_data:
                            df = excel_data[self.sheet_name]
                            logger.info(f"Usando aba '{self.sheet_name}' do arquivo Excel")
                        else:
                            first_sheet = list(excel_data.keys())[0]
                            df = excel_data[first_sheet]
                            logger.warning(f"Aba '{self.sheet_name}' não encontrada. Usando primeira aba: '{first_sheet}'")
                    else:
                        first_sheet = list(excel_data.keys())[0]
                        df = excel_data[first_sheet]
                        logger.info(f"Arquivo tem múltiplas abas. Usando primeira aba: '{first_sheet}'")
                elif isinstance(excel_data, pd.DataFrame):
                    df = excel_data
                else:
                    raise ValueError(f"Formato de dados inesperado retornado pelo pandas: {type(excel_data)}")
                
                if df is None or df.empty:
                    raise ValueError("A planilha Excel está vazia ou não contém dados")
            
            # Normaliza nomes de colunas
            normalized_columns = []
            for idx, col in enumerate(df.columns):
                try:
                    if col is None or pd.isna(col):
                        normalized_col = f"COLUNA_{idx+1}"
                        logger.warning(f"Coluna {idx} está vazia/None, renomeando para {normalized_col}")
                    else:
                        normalized_col = str(col).strip()
                        if not normalized_col:
                            normalized_col = f"COLUNA_{idx+1}"
                            logger.warning(f"Coluna {idx} ficou vazia após normalização, renomeando para {normalized_col}")
                except Exception as e:
                    normalized_col = f"COLUNA_{idx+1}"
                    logger.error(f"Erro ao normalizar coluna {idx} ('{col}'): {e}. Renomeando para {normalized_col}")
                
                normalized_columns.append(normalized_col)
            
            df.columns = normalized_columns
            
            # Para CSV, mantém case original. Para Excel, converte para uppercase
            if file_format != 'csv':
                df.columns = [c.upper() for c in df.columns]
            
            logger.info(f"Arquivo lido: {len(df)} linhas, {len(df.columns)} colunas")
            logger.debug(f"Colunas encontradas: {list(df.columns)}")
            
            return df
        except Exception as e:
            logger.error(f"Erro ao ler arquivo '{file_path}': {e}")
            raise ValueError(f"Erro ao processar arquivo: {str(e)}")

    def validate_columns(self, df: pd.DataFrame, file_format: str = None) -> None:
        """Valida se as colunas obrigatórias estão presentes"""
        if file_format is None:
            # Detecta formato pelas colunas presentes
            has_csv_cols = all(col in df.columns for col in ['codigo', 'Nome'])
            has_old_excel_cols = all(col in df.columns for col in ['PRODUTO', 'CATEGORIA'])
            
            if has_csv_cols:
                file_format = 'csv'
            elif has_old_excel_cols:
                file_format = 'excel'
            else:
                raise ValueError(
                    f"Formato não reconhecido. Colunas encontradas: {list(df.columns)}"
                )
        
        # Se tiver colunas do CSV (novo formato), valida como CSV (funciona para Excel também)
        if file_format == 'csv' or all(col in df.columns for col in ['codigo', 'Nome']):
            missing = [c for c in REQUIRED_COLUMNS_CSV if c not in df.columns]
            if missing:
                raise ValueError(
                    f"Colunas obrigatórias ausentes: {missing}. "
                    f"Colunas disponíveis: {list(df.columns)}"
                )
        else:  # excel antigo
            missing = [c for c in REQUIRED_COLUMNS_EXCEL if c not in df.columns]
            if missing:
                raise ValueError(
                    f"Colunas obrigatórias ausentes no Excel: {missing}. "
                    f"Colunas disponíveis: {list(df.columns)}"
                )

    def _parse_brazilian_decimal(self, value: Any) -> Optional[Decimal]:
        """Converte valor brasileiro (vírgula como decimal) ou numérico para Decimal"""
        if pd.isna(value):
            return None
        
        try:
            # Se já for numérico (float/int), converte diretamente
            if isinstance(value, (int, float)):
                return Decimal(str(value)).quantize(Decimal("0.01"))
            
            # Se for string, trata como formato brasileiro
            str_value = str(value).strip()
            # Remove pontos (milhares) e substitui vírgula por ponto (decimal)
            str_value = str_value.replace('.', '').replace(',', '.')
            return Decimal(str_value).quantize(Decimal("0.01"))
        except Exception:
            return None

    def extract_entities(self, df: pd.DataFrame, file_format: str = None) -> Tuple[List[Dict[str, Any]], Dict[str, List[str]]]:
        """
        Retorna (produtos_list, kits_map)
        - produtos_list: lista de dicionários com campos limpos
        - kits_map: { kit_codigo: [produto_codigo, ...] }
        """
        # Detecta formato pelas colunas (CSV e Excel novos têm mesma estrutura)
        has_csv_cols = all(col in df.columns for col in ['codigo', 'Nome'])
        has_old_excel_cols = all(col in df.columns for col in ['PRODUTO', 'CATEGORIA'])
        
        if file_format is None:
            if has_csv_cols:
                file_format = 'csv'
            elif has_old_excel_cols:
                file_format = 'excel'
            else:
                file_format = 'csv'  # Default para novo formato

        # Excel novo (mesma estrutura do CSV) usa método CSV
        if file_format == 'csv' or has_csv_cols:
            return self._extract_entities_csv(df)
        else:
            return self._extract_entities_excel(df)

    def _extract_entities_csv(self, df: pd.DataFrame) -> Tuple[List[Dict[str, Any]], Dict[str, List[str]]]:
        """Extrai entidades do formato CSV"""
        produtos = []
        kits_map = {}
        
        for idx, row in df.iterrows():
            try:
                codigo = str(row.get('codigo', '') or '').strip()
                nome = str(row.get('Nome', '') or '').strip()
                
                if not codigo and not nome:
                    logger.debug(f"Linha {idx+2} ignorada: sem código e nome")
                    continue
                
                if not codigo:
                    codigo = f"PROD-{nome[:20].upper().replace(' ', '-')}"
                
                id_categoria = row.get('id_categoria')
                id_subcategoria = row.get('id_subcategoria')
                quantidade = row.get('Quantidade', 1)
                descricao = row.get('Descricao')
                descricao = None if pd.isna(descricao) else str(descricao).strip()
                
                codigo_amarracao = row.get('Codigo Amarração')
                # Trata valores numéricos do pandas (float64) e strings
                # Mantém como string (mesmo tipo do codigo)
                if pd.isna(codigo_amarracao) or codigo_amarracao == '':
                    codigo_amarracao = None
                else:
                    # Converte para string (pandas retorna 9089.0 como float)
                    try:
                        if isinstance(codigo_amarracao, (int, float)):
                            codigo_amarracao = str(int(float(codigo_amarracao)))
                        else:
                            codigo_amarracao = str(codigo_amarracao).strip()
                        # Se ficou vazio após strip, retorna None
                        if not codigo_amarracao:
                            codigo_amarracao = None
                    except (ValueError, TypeError):
                        codigo_amarracao = None
                
                # Valores monetários
                vlr_unitario = self._parse_brazilian_decimal(row.get('Vlr Unitario'))
                vlr_bruto = self._parse_brazilian_decimal(row.get('Vlr Bruto'))
                
                # Se tem código amarração, é um kit do produto base
                is_kit = codigo_amarracao is not None and codigo_amarracao != ''
                
                # Extrai image_url (pode vir em diferentes nomes de coluna)
                image_urls = self._extract_image_urls(row)
                
                produto = {
                    "codigo": codigo,
                    "nome": nome,
                    "descricao": descricao,
                    "id_categoria": int(id_categoria) if pd.notna(id_categoria) else None,
                    "id_subcategoria": int(id_subcategoria) if pd.notna(id_subcategoria) else None,
                    "quantidade": int(quantidade) if pd.notna(quantidade) else 1,
                    "valor_base": vlr_unitario or vlr_bruto,
                    "codigo_amarracao": codigo_amarracao,
                    "is_kit": is_kit,
                    "image_urls": image_urls  # Array de URLs
                }
                
                produtos.append(produto)
                
                # Registra no mapa de kits (código produto base -> lista de códigos kits)
                if is_kit and codigo_amarracao:
                    kits_map.setdefault(codigo_amarracao, []).append(codigo)
                    
            except Exception as e:
                logger.warning(f"Erro parsing linha {idx+2}: {e}")
                continue

        return produtos, kits_map

    def _extract_image_urls(self, row: pd.Series) -> List[str]:
        """Extrai URLs de imagem do CSV. Suporta múltiplos formatos:
        - Array JSON: ["url1", "url2"]
        - Array sem aspas: [url1, url2]
        - Separado por vírgula: "url1,url2,url3"
        - Separado por ponto e vírgula: "url1;url2;url3"
        - String simples: "url1"
        """
        import json
        
        # Tenta diferentes nomes de coluna
        col_names = ['image_url', 'image_urls', 'imagem_url', 'imagens_url', 'url_imagem', 'url_imagens']
        image_data = None
        
        for col_name in col_names:
            if col_name in row.index:
                image_data = row.get(col_name)
                if pd.notna(image_data):
                    break
        
        if image_data is None or pd.isna(image_data):
            return []
        
        # Converte para string
        image_str = str(image_data).strip()
        if not image_str:
            return []
        
        # Tenta parsear como JSON (array com aspas)
        try:
            parsed = json.loads(image_str)
            if isinstance(parsed, list):
                # Remove URLs vazias e retorna lista limpa
                return [url.strip() for url in parsed if url and str(url).strip()]
            elif isinstance(parsed, str):
                # Se JSON retornou string, processa como string separada
                image_str = parsed
        except (json.JSONDecodeError, ValueError):
            # Não é JSON válido, tenta formato array sem aspas [url1, url2]
            if image_str.startswith('[') and image_str.endswith(']'):
                # Remove colchetes e processa como vírgulas
                image_str = image_str[1:-1].strip()
            # Continua processamento abaixo
        
        # Processa como string separada (vírgula ou ponto e vírgula)
        urls = []
        if image_str:
            # Tenta separar por ponto e vírgula primeiro, depois por vírgula
            if ';' in image_str:
                urls = [url.strip() for url in image_str.split(';') if url.strip()]
            elif ',' in image_str:
                urls = [url.strip() for url in image_str.split(',') if url.strip()]
            else:
                # String única
                urls = [image_str]
        
        # Remove URLs vazias e limpa
        urls = [url.strip() for url in urls if url and url.strip()]
        
        return urls

    def _extract_entities_excel(self, df: pd.DataFrame) -> Tuple[List[Dict[str, Any]], Dict[str, List[str]]]:
        """Extrai entidades do formato Excel (método original)"""
        produtos = []
        kits_map = {}

        for idx, row in df.iterrows():
            try:
                nome = str(row.get('PRODUTO') or "").strip()
                if not nome:
                    logger.debug(f"linha {idx+2} ignorada: sem PRODUTO")
                    continue

                categoria = str(row.get('CATEGORIA') or "").strip()
                subcategoria = str(row.get('SUBCATEGORIA') or "").strip()
                descricao = row.get('DESCRIÇÃO')
                descricao = None if pd.isna(descricao) else str(descricao).strip()

                regiao = str(row.get('REGIÃO') or "").strip()
                prazo = str(row.get('PRAZO DE ENTREGA') or "").strip()

                valor_raw = row.get('VALOR UNITÁRIO', None)
                valor = None
                if pd.notna(valor_raw):
                    try:
                        valor = Decimal(str(valor_raw)).quantize(Decimal("0.01"))
                    except Exception:
                        valor = None

                kit_name = None
                kit_val = row.get('KIT')
                if pd.notna(kit_val):
                    kit_name = str(kit_val).strip()
                    kits_map.setdefault(kit_name, []).append(nome)

                produto = {
                    "nome": nome,
                    "descricao": descricao,
                    "categoria": categoria,
                    "subcategoria": subcategoria,
                    "regiao": regiao,
                    "prazo": prazo,
                    "valor_base": valor,
                    "kit": kit_name,
                }
                produtos.append(produto)
            except Exception as e:
                logger.warning(f"Erro parsing linha {idx+2}: {e}")
                continue

        return produtos, kits_map
