"""Persistência de pedidos com itens — compartilhada entre fluxos (e-mail, recompra, etc.)."""

from decimal import Decimal
from typing import Any, Sequence

from app.domain.models.order_model import Order
from app.domain.models.order_item_model import OrderItem
from app.infrastructure.repositories.order_repository_interface import IOrderRepository

IPI_ALIQUOTA = Decimal("0.065")


def compute_total_order_value_with_ipi_from_subtotal(subtotal_sem_ipi: Decimal) -> Decimal:
    """Total do pedido com IPI (mesma regra do envio por e-mail)."""
    valor_ipi = (subtotal_sem_ipi * IPI_ALIQUOTA).quantize(Decimal("0.01"))
    return subtotal_sem_ipi + valor_ipi


def create_order_with_items(
    company_id: int,
    itens: Sequence[Any],
    session,
    order_repository: IOrderRepository,
) -> Order:
    """
    Persiste pedido e itens. Cada item deve expor:
    id_produto, quantidade_pedida, valor_unitario, valor_total (como no OrderItemUseCaseRequest).
    """
    subtotal_sem_ipi = Decimal("0")
    for item in itens:
        subtotal_sem_ipi += Decimal(str(item.valor_total))

    valor_total = compute_total_order_value_with_ipi_from_subtotal(subtotal_sem_ipi)

    order = Order(id_cliente=company_id, valor_total=valor_total)
    for item in itens:
        order_item = OrderItem(
            id_pedido=0,
            id_produto=item.id_produto,
            quantidade=item.quantidade_pedida,
            preco_unitario=Decimal(str(item.valor_unitario)),
            subtotal=Decimal(str(item.valor_total)),
        )
        order.itens.append(order_item)

    return order_repository.create_order_with_items(order, session)
