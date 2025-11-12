class CompanyDTO:

    def __init__(self, id, name, role):
        self.id = id
        self.name = name
        self.role = role


    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "role": self.role
        }
