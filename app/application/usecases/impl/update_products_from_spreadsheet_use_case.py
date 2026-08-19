"""Atualiza nome e valor-base de produtos a partir de uma planilha."""

from decimal import Decimal, InvalidOperation
from typing import Any, Dict, List

import pandas as pd
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.application.usecases.use_case import UseCase
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.product_repository_interface import IProductRepository


class UpdateProductsFromSpreadsheetUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Atualização parcial em lote, identificando produtos exclusivamente pelo código."""

    REQUIRED_COLUMNS = {"codigo", "nome", "valor_base"}

    def __init__(self, product_repository: IProductRepository | None = None):
        self.product_repository = product_repository or ProductRepositoryImpl()

    def execute(self, data: Dict[str, Any], session: Session = None) -> Dict[str, Any]:
        file_path = data.get("file_path")
        file_format = data.get("file_format")
        if not file_path or not file_format:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Arquivo e formato são obrigatórios")

        rows = self._read_rows(file_path, file_format)
        products_by_code = self.product_repository.get_by_codigos([row["codigo"] for row in rows], session)

        updated = 0
        unchanged = 0
        not_found_codes: List[str] = []
        for row in rows:
            product = products_by_code.get(row["codigo"])
            if product is None:
                not_found_codes.append(row["codigo"])
                continue

            if product.nome == row["nome"] and product.valor_base == row["valor_base"]:
                unchanged += 1
                continue

            # Esta importação é um PATCH: nenhum outro atributo pode ser alterado aqui.
            product.nome = row["nome"]
            product.valor_base = row["valor_base"]
            self.product_repository.update(product, session)
            updated += 1

        return {
            "success": True,
            "message": "Atualização parcial concluída",
            "summary": {
                "total_rows": len(rows),
                "updated": updated,
                "unchanged": unchanged,
                "not_found": len(not_found_codes),
                "not_found_codes": not_found_codes,
            },
        }

    def _read_rows(self, file_path: str, file_format: str) -> List[Dict[str, Any]]:
        try:
            if file_format == "csv":
                dataframe = pd.read_csv(file_path, sep=None, engine="python", dtype={"codigo": str})
            elif file_format == "excel":
                dataframe = pd.read_excel(file_path, dtype={"codigo": str})
            else:
                raise ValueError("Formato de arquivo não suportado")
        except Exception as exc:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Não foi possível ler a planilha: {exc}") from exc

        dataframe.columns = [str(column).strip().lower() for column in dataframe.columns]
        received_columns = set(dataframe.columns)
        if received_columns != self.REQUIRED_COLUMNS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A planilha deve possuir exatamente as colunas: codigo, nome, valor_base",
            )

        rows: List[Dict[str, Any]] = []
        seen_codes = set()
        errors = []
        for index, raw in dataframe.iterrows():
            line = index + 2
            try:
                # Linhas sem código e sem valor não representam um produto. Alguns ERPs
                # as incluem no CSV, inclusive com um nome/resíduo de texto preenchido.
                # Elas são ignoradas; uma linha com somente um desses campos continua inválida.
                missing_code = pd.isna(raw["codigo"]) or not str(raw["codigo"]).strip()
                missing_value = pd.isna(raw["valor_base"]) or not str(raw["valor_base"]).strip()
                if missing_code and missing_value:
                    continue

                code = self._normalize_code(raw["codigo"])
                name = self._required_text(raw["nome"], "nome")
                value = self._parse_decimal(raw["valor_base"])
                if code in seen_codes:
                    raise ValueError(f"codigo duplicado: {code}")
                seen_codes.add(code)
                rows.append({"codigo": code, "nome": name, "valor_base": value})
            except ValueError as exc:
                errors.append({"line": line, "error": str(exc)})

        if errors:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail={"message": "Planilha inválida", "errors": errors})
        if not rows:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="A planilha não possui linhas para atualizar")
        return rows

    @staticmethod
    def _normalize_code(value: Any) -> str:
        if pd.isna(value):
            raise ValueError("codigo é obrigatório")
        code = str(value).strip()
        if code.endswith(".0") and code[:-2].isdigit():
            code = code[:-2]
        if not code:
            raise ValueError("codigo é obrigatório")
        return code

    @staticmethod
    def _required_text(value: Any, field: str) -> str:
        if pd.isna(value) or not str(value).strip():
            raise ValueError(f"{field} é obrigatório")
        return str(value).strip()

    @staticmethod
    def _parse_decimal(value: Any) -> Decimal:
        if pd.isna(value):
            raise ValueError("valor_base é obrigatório")
        normalized = str(value).strip().replace("R$", "").replace(" ", "")
        if "," in normalized:
            normalized = normalized.replace(".", "").replace(",", ".")
        try:
            decimal_value = Decimal(normalized).quantize(Decimal("0.01"))
        except (InvalidOperation, ValueError) as exc:
            raise ValueError("valor_base inválido") from exc
        if decimal_value < 0:
            raise ValueError("valor_base não pode ser negativo")
        return decimal_value
