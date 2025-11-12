
class HeaderResponseDTO:

    def __init__(self, authorization):
        self.authorization = authorization

    def to_dict(self):
        return {
            "authorization": self.authorization
        }
