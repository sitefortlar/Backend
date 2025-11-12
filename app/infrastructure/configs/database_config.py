
from loguru import logger
from sqlalchemy import create_engine, QueuePool
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import sessionmaker

import envs
from app.domain import models
from app.infrastructure.configs.base_mixin import Base


def __connection_status(engine):
    try:
        with engine.connect() as connection:
            logger.info("Database connection successful")
    except SQLAlchemyError as e:
        logger.error(f"Error connecting to the database: {e}")
    except Exception as e:
        logger.exception(f"Unexpected error while trying to connect to the database: {e}")


engine = create_engine(
    envs.SQLALCHEMY_DATABASE_URI,
    pool_size=envs.SQLALCHEMY_POOL_SIZE,
    max_overflow=envs.SQLALCHEMY_MAX_OVERFLOW,
    pool_timeout=envs.SQLALCHEMY_POOL_TIMEOUT,
    pool_recycle=envs.SQLALCHEMY_POOL_RECYCLE,
    pool_pre_ping=envs.SQLALCHEMY_POOL_PRE_PING,
    echo=envs.SQLALCHEMY_SHOW_SQL,
    poolclass=QueuePool
)

__connection_status(engine)

Session = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False
)


def init_db():
    Base.metadata.create_all(bind=engine)

