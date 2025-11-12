import time
from contextlib import contextmanager
from loguru import logger
from app.infrastructure.configs.database_config import Session

@contextmanager
def __session_scope():
    start_time = time.time()
    session = Session()
    try:
        logger.debug("=== Starting a new session ===")
        yield session
        session.commit()
        session.expunge_all()
        logger.debug("=== Session committed ===")
    except Exception as e:
        if session.is_active:
            session.rollback()
        logger.error(f"=== Session Rollback: error {e} ===")
        raise
    finally:
        session.close()
        execution_time = time.time() - start_time
        logger.info(f"Connection check took {execution_time:.4f} seconds")
        logger.debug("=== Session closed ===")

def get_session():
    with __session_scope() as session:
        yield session
