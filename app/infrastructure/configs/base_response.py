from pydantic import BaseModel
from datetime import datetime
from enum import Enum
from typing import Any, Dict


class BaseResponseModel(BaseModel):
    class Config:
        orm_mode = True  # Permite passar models ORM diretamente
        use_enum_values = True  # Serializa enums para seus valores

    def to_dict(self, include_none: bool = True) -> Dict[str, Any]:
        """
        Converte o model para dict, convertendo datetimes para isoformat e enums para valores.
        Pode remover campos None se include_none=False.
        """
        def serialize_value(value):
            if isinstance(value, datetime):
                return value.isoformat()
            elif isinstance(value, Enum):
                return value.value
            elif isinstance(value, list):
                return [serialize_value(v) for v in value]
            elif isinstance(value, dict):
                return {k: serialize_value(v) for k, v in value.items()}
            else:
                return value

        data = self.dict()
        data = {k: serialize_value(v) for k, v in data.items()}

        if not include_none:
            data = {k: v for k, v in data.items() if v is not None}

        return data
