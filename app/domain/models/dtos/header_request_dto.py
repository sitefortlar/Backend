from wsgiref.headers import Headers


class HeaderRequestDTO:
    def __init__(self, headers: Headers):
        self.headers = headers

    def to_dict(self):
        return {
            "headers": self.headers,
        }
