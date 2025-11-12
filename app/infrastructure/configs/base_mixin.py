from sqlalchemy.orm import declarative_base, Mapped, mapped_column
from sqlalchemy.inspection import inspect
from sqlalchemy.sql import func
from datetime import datetime
from enum import Enum
from typing import Any, Dict, Optional

Base = declarative_base()

class TimestampMixin:
    """Mixin para adicionar campos de timestamp automaticamente"""
    created_at: Mapped[datetime] = mapped_column(
        nullable=False, 
        server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        nullable=False, 
        server_default=func.now(), 
        onupdate=func.now()
    )

class BaseMixin:
    def to_dict(self, include_relationships=False, backref_depth=1):
        mapper = inspect(self).mapper
        data = {}

        for column in mapper.column_attrs:
            value = getattr(self, column.key)
            if isinstance(value, datetime):
                value = value.isoformat()
            elif isinstance(value, Enum):
                value = value.value
            data[column.key] = value

        if include_relationships and backref_depth > 0:
            for rel in mapper.relationships:
                value = getattr(self, rel.key)
                if value is None:
                    data[rel.key] = None
                elif rel.uselist:
                    data[rel.key] = [item.to_dict(include_relationships, backref_depth - 1) for item in value]
                else:
                    data[rel.key] = value.to_dict(include_relationships, backref_depth - 1)

        return data

    def __repr__(self):
        """Retorna representação legível para debug."""
        attrs = ", ".join(f"{c.name}={getattr(self, c.name)!r}" for c in self.__table__.columns)
        return f"<{self.__class__.__name__}({attrs})>"

    def get(self, field):
        """Retorna o valor de um campo específico."""
        return getattr(self, field, None)

