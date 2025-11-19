class ExistingRecordException(Exception):
    """Exceção lançada quando um registro já existe no banco de dados."""
    def __init__(self, message: str = "Registro já existe"):
        self.message = message
        super().__init__(self.message)
