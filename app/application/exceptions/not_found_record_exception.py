class NotFoundRecordException(Exception):
    """Exceção lançada quando um registro não é encontrado."""
    def __init__(self, message: str = "Registro não encontrado"):
        self.message = message
        super().__init__(self.message)
