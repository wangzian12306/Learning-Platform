from typing import Sequence

from app.models import ChatRole


class ChatRepository:
    @staticmethod
    def save_message(connection, user_id: int, session_id: str, role: ChatRole, content: str) -> int:
        sql = """
        INSERT INTO ai_chat (user_id, session_id, role, content)
        VALUES (%s, %s, %s, %s)
        """
        with connection.cursor() as cursor:
            cursor.execute(sql, (user_id, session_id, role.value, content))
            return cursor.lastrowid

    @staticmethod
    def get_session_messages(connection, user_id: int, session_id: str, limit: int) -> Sequence[dict]:
        sql = """
        SELECT role, content, create_time
        FROM ai_chat
        WHERE user_id = %s
          AND session_id = %s
        ORDER BY create_time DESC, id DESC
        LIMIT %s
        """
        with connection.cursor() as cursor:
            cursor.execute(sql, (user_id, session_id, limit))
            rows = cursor.fetchall()
        rows.reverse()
        return rows
