from contextlib import contextmanager

import pymysql
from pymysql.cursors import DictCursor

from app.config import get_settings


def _build_connection():
    settings = get_settings()
    return pymysql.connect(
        host=settings.mysql_host,
        port=settings.mysql_port,
        user=settings.mysql_user,
        password=settings.mysql_password,
        database=settings.mysql_database,
        cursorclass=DictCursor,
        autocommit=False,
        charset="utf8mb4",
    )


@contextmanager
def get_db():
    connection = _build_connection()
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()
