"""Use case para calcular preços de itens do carrinho por região e prazo"""

from typing import Dict, Any, List, Optional
from fastapi import HTTPException, status
from decimal import Decimal, ROUND_HALF_UP

from app.application.usecases.use_case import UseCase
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.region_repository_interface import IRegionRepository
from app.infrastructure.repositories.impl.region_repository_impl import RegionRepositoryImpl


class GetCartPricesUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """
    Calcula o preço unitário de produtos para o carrinho.

    Regras:
    - estado MG e ES usam seus próprios descontos
    - outros estados usam SP (fallback)
    - prazo: 0 (avista), 30, 60
    - preço calculado: valor_base * desconto_{prazo} (mesma lógica do list_products)
    """

    def __init__(self):
        self.product_repository: IProductRepository = ProductRepositoryImpl()
        self.region_repository: IRegionRepository = RegionRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        estado: Optional[str] = request.get("estado")
        prazo: Optional[int] = request.get("prazo")
        product_ids: List[int] = request.get("product_ids") or []

        if not estado:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="estado é obrigatório")

        if prazo not in (0, 30, 60):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="prazo deve ser 0, 30 ou 60")

        if not product_ids:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="ids de produtos são obrigatórios")

        # Estado para cálculo: MG/ES usam descontos próprios; restante usa SP
        estado_request = estado.strip().upper()
        estado_calculo = estado_request if estado_request in ("MG", "ES") else "SP"

        region = self.region_repository.get_by_estado(estado_calculo, session)
        if not region:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Região '{estado_calculo}' não encontrada na base de dados"
            )

        if prazo == 0:
            multiplier = Decimal(str(region.desconto_0))
        elif prazo == 30:
            multiplier = Decimal(str(region.desconto_30))
        else:
            multiplier = Decimal(str(region.desconto_60))

        # Busca produtos em lote
        unique_ids = list(dict.fromkeys(product_ids))
        products = self.product_repository.get_by_ids(unique_ids, session=session)
        product_map = {p.id_produto: p for p in products}

        items: List[Dict[str, Any]] = []
        for pid in product_ids:
            p = product_map.get(pid)
            if not p:
                items.append({
                    "id_produto": pid,
                    "found": False,
                    "codigo": None,
                    "nome": None,
                    "ativo": None,
                    "valor_base": None,
                    "preco": None,
                    "error": "Produto não encontrado"
                })
                continue

            valor_base = Decimal(str(p.valor_base))
            preco = (valor_base * multiplier).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

            items.append({
                "id_produto": p.id_produto,
                "found": True,
                "codigo": p.codigo,
                "nome": p.nome,
                "ativo": bool(p.ativo),
                "valor_base": float(valor_base),
                "preco": float(preco),
                "error": None
            })

        return {
            "estado_request": estado_request,
            "estado_calculo": estado_calculo,
            "prazo": prazo,
            "multiplier": float(multiplier),
            "items": items
        }


