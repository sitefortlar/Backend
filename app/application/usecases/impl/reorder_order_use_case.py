"""Caso de uso: recompra (novo pedido a partir de um pedido anterior, com preços atuais)."""

from decimal import Decimal
from typing import Any, Dict

from fastapi import HTTPException, status

from app.application.service.order_creation_service import create_order_with_items
from app.application.usecases.impl.get_order_use_case import GetOrderUseCase
from app.application.usecases.use_case import UseCase
from app.domain.models.dtos.send_order_email_dto import OrderItemUseCaseRequest
from app.domain.models.enumerations.role_enumerations import RoleEnum
from app.infrastructure.repositories.order_repository_interface import IOrderRepository
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl
from app.infrastructure.repositories.product_repository_interface import IProductRepository
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl


class ReorderOrderUseCase(UseCase[Dict[str, Any], Dict[str, Any]]):
    """Duplica itens de um pedido em um novo pedido PENDENTE, usando preço atual (valor_base)."""

    def __init__(self):
        self.order_repository: IOrderRepository = OrderRepositoryImpl()
        self.product_repository: IProductRepository = ProductRepositoryImpl()

    def execute(self, request: Dict[str, Any], session=None) -> Dict[str, Any]:
        pedido_id = request.get("pedido_id")
        requester_id = request.get("requester_company_id")
        requester_role = request.get("requester_role")

        if pedido_id is None or requester_id is None or requester_role is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Dados de recompra inválidos",
            )

        original = self.order_repository.get_orders_with_items(pedido_id, session)
        if not original:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Order não encontrado",
            )

        if requester_role != RoleEnum.ADMIN and original.id_cliente != requester_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Order não encontrado",
            )

        if not original.itens:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Pedido original não possui itens",
            )

        product_ids = [item.id_produto for item in original.itens]
        products = self.product_repository.get_by_ids(product_ids, session)
        by_id = {p.id_produto: p for p in products}

        priced_lines: list[OrderItemUseCaseRequest] = []
        for line in original.itens:
            produto = by_id.get(line.id_produto)
            if produto is None or not produto.ativo:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Produto id={line.id_produto} indisponível para recompra",
                )

            unit_dec = (
                produto.valor_base
                if isinstance(produto.valor_base, Decimal)
                else Decimal(str(produto.valor_base))
            )
            qty = int(line.quantidade)
            line_total = float((unit_dec * Decimal(qty)).quantize(Decimal("0.01")))
            unit = float(unit_dec)

            priced_lines.append(
                OrderItemUseCaseRequest(
                    id_produto=produto.id_produto,
                    codigo=produto.codigo,
                    nome=produto.nome,
                    quantidade_pedida=qty,
                    valor_unitario=unit,
                    valor_total=line_total,
                    categoria=None,
                    subcategoria=None,
                )
            )

        new_order = create_order_with_items(
            company_id=original.id_cliente,
            itens=priced_lines,
            session=session,
            order_repository=self.order_repository,
        )

        return GetOrderUseCase().execute(
            {"pedido_id": new_order.id_pedido, "include_items": True},
            session,
        )
