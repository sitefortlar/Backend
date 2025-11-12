"""Serviço para processamento de planilhas Excel"""

import pandas as pd
from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)


class ExcelService:
    """Serviço para processamento de arquivos Excel"""

    def __init__(self):
        self.required_columns = [
            'codigo', 'nome', 'descricao', 'id_categoria', 
            'id_subcategoria', 'valor_base', 'ativo'
        ]

    def process_excel_file(self, file_path: str) -> List[Dict[str, Any]]:
        """
        Processa arquivo Excel e retorna lista de produtos
        
        Args:
            file_path: Caminho para o arquivo Excel
            
        Returns:
            Lista de dicionários com dados dos produtos
            
        Raises:
            HTTPException: Se houver erro no processamento
        """
        try:
            # Lê o arquivo Excel
            df = pd.read_excel(file_path)
            
            # Valida se as colunas necessárias existem
            self._validate_columns(df)
            
            # Processa linha por linha
            produtos = []
            for index, row in df.iterrows():
                try:
                    produto_data = self._process_row(row, index + 2)  # +2 porque Excel começa em 1 e tem header
                    produtos.append(produto_data)
                except Exception as e:
                    logger.warning(f"Erro na linha {index + 2}: {str(e)}")
                    # Continua processando outras linhas mesmo se uma falhar
                    continue
            
            if not produtos:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Nenhum produto válido encontrado na planilha"
                )
            
            logger.info(f"Processados {len(produtos)} produtos da planilha")
            return produtos
            
        except FileNotFoundError:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Arquivo Excel não encontrado"
            )
        except pd.errors.EmptyDataError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo Excel está vazio"
            )
        except pd.errors.ExcelFileError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo Excel inválido ou corrompido"
            )
        except Exception as e:
            logger.error(f"Erro ao processar arquivo Excel: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao processar arquivo Excel: {str(e)}"
            )

    def _validate_columns(self, df: pd.DataFrame) -> None:
        """
        Valida se as colunas necessárias existem no DataFrame
        
        Args:
            df: DataFrame do pandas
            
        Raises:
            HTTPException: Se colunas necessárias não existirem
        """
        missing_columns = []
        for column in self.required_columns:
            if column not in df.columns:
                missing_columns.append(column)
        
        if missing_columns:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Colunas obrigatórias não encontradas: {', '.join(missing_columns)}. "
                       f"Colunas necessárias: {', '.join(self.required_columns)}"
            )

    def _process_row(self, row: pd.Series, row_number: int) -> Dict[str, Any]:
        """
        Processa uma linha individual do Excel
        
        Args:
            row: Linha do DataFrame
            row_number: Número da linha (para logs de erro)
            
        Returns:
            Dicionário com dados do produto processado
            
        Raises:
            HTTPException: Se houver erro no processamento da linha
        """
        try:
            # Valida e converte dados
            codigo = str(row['codigo']).strip()
            if not codigo:
                raise ValueError("Código do produto não pode estar vazio")
            
            nome = str(row['nome']).strip()
            if not nome:
                raise ValueError("Nome do produto não pode estar vazio")
            
            descricao = str(row['descricao']).strip() if pd.notna(row['descricao']) else None
            if descricao == 'nan':
                descricao = None
            
            # Valida IDs de categoria e subcategoria
            try:
                id_categoria = int(row['id_categoria'])
                if id_categoria <= 0:
                    raise ValueError("ID da categoria deve ser maior que zero")
            except (ValueError, TypeError):
                raise ValueError("ID da categoria deve ser um número inteiro válido")
            
            try:
                id_subcategoria = int(row['id_subcategoria'])
                if id_subcategoria <= 0:
                    raise ValueError("ID da subcategoria deve ser maior que zero")
            except (ValueError, TypeError):
                raise ValueError("ID da subcategoria deve ser um número inteiro válido")
            
            # Valida valor base
            try:
                valor_base = float(row['valor_base'])
                if valor_base < 0:
                    raise ValueError("Valor base não pode ser negativo")
                valor_base = Decimal(str(valor_base))
            except (ValueError, TypeError):
                raise ValueError("Valor base deve ser um número válido")
            
            # Valida status ativo
            ativo = True
            if pd.notna(row['ativo']):
                if isinstance(row['ativo'], bool):
                    ativo = row['ativo']
                elif isinstance(row['ativo'], str):
                    ativo = row['ativo'].lower() in ['true', '1', 'sim', 's', 'yes', 'y']
                elif isinstance(row['ativo'], (int, float)):
                    ativo = bool(row['ativo'])
            
            return {
                'codigo': codigo,
                'nome': nome,
                'descricao': descricao,
                'id_categoria': id_categoria,
                'id_subcategoria': id_subcategoria,
                'valor_base': valor_base,
                'ativo': ativo
            }
            
        except Exception as e:
            raise ValueError(f"Linha {row_number}: {str(e)}")

    def validate_excel_structure(self, file_path: str) -> Dict[str, Any]:
        """
        Valida a estrutura do arquivo Excel sem processar os dados
        
        Args:
            file_path: Caminho para o arquivo Excel
            
        Returns:
            Dicionário com informações de validação
        """
        try:
            # Lê apenas o cabeçalho
            df = pd.read_excel(file_path, nrows=0)
            
            # Valida colunas
            self._validate_columns(df)
            
            # Conta linhas de dados
            df_full = pd.read_excel(file_path)
            total_rows = len(df_full)
            
            return {
                'valid': True,
                'total_rows': total_rows,
                'columns': list(df.columns),
                'message': f"Arquivo válido com {total_rows} linhas de dados"
            }
            
        except Exception as e:
            return {
                'valid': False,
                'error': str(e),
                'message': f"Arquivo inválido: {str(e)}"
            }
