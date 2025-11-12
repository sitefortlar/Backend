from enum import Enum

class EmailTokenTypeEnum(str, Enum):
    VALIDACAO_EMAIL = "VALIDACAO_EMAIL"
    RESET_SENHA = "RESET_SENHA"
