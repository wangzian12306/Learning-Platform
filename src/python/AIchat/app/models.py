from enum import Enum


class ChatRole(str, Enum):
    USER = "USER"
    ASSISTANT = "ASSISTANT"


class AIAbility(str, Enum):
    QA = "qa"
    CODE_ANALYSIS = "code-analysis"
    CODE_GENERATION = "code-generation"
