import enum

class OrderStatusEnum(str, enum.Enum):
    """Enum para status do order"""
    PENDENTE = 'pendente'
    CONFIRMADO = 'confirmado'
    EM_PREPARACAO = 'em_preparacao'
    ENVIADO = 'enviado'
    CONCLUIDO = 'concluido'
    CANCELADO = 'cancelado'
