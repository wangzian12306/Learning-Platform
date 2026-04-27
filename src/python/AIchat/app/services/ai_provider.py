from typing import Optional

from openai import OpenAI

from app.config import get_settings
from app.key_store import get_provider_key, load_api_keys
from app.models import AIAbility


class AIProvider:
    def __init__(self):
        settings = get_settings()
        keys = load_api_keys(settings.api_key_file)
        api_key = get_provider_key(keys, "qwen")
        self.client = OpenAI(api_key=api_key, base_url=settings.qwen_base_url)
        self.default_model = settings.qwen_model

    def generate(self, ability: AIAbility, messages: list[dict], model: Optional[str] = None) -> str:
        selected_model = (model or self.default_model).strip()
        if selected_model.startswith("deepseek-"):
            return self._generate_with_chat_completions(selected_model, messages)
        return self._generate_with_responses(selected_model, messages, ability)

    def generate_stream(self, messages: list[dict], model: Optional[str] = None):
        selected_model = (model or self.default_model).strip()
        if selected_model.startswith("deepseek-"):
            yield from self._generate_with_chat_completions_stream(selected_model, messages)
            return
        yield from self._generate_with_responses_stream(selected_model, messages)

    def _generate_with_responses(self, model: str, messages: list[dict], ability: AIAbility) -> str:
        response = self.client.responses.create(
            model=model,
            input=messages,
            extra_body={"enable_thinking": True},
        )

        output_text = getattr(response, "output_text", None)
        if output_text:
            return output_text

        reasoning_summary = []
        output = getattr(response, "output", []) or []
        for item in output:
            if getattr(item, "type", None) == "reasoning":
                for summary in getattr(item, "summary", []) or []:
                    summary_text = getattr(summary, "text", None)
                    if summary_text:
                        reasoning_summary.append(summary_text)
            if getattr(item, "type", None) == "message":
                for content in getattr(item, "content", []) or []:
                    text = getattr(content, "text", None)
                    if text:
                        return text

        if reasoning_summary:
            return "\n".join(reasoning_summary)

        raise RuntimeError(f"千问响应中未获取到文本输出（ability={ability.value}, model={model}）。")

    def _generate_with_chat_completions(self, model: str, messages: list[dict]) -> str:
        completion = self.client.chat.completions.create(
            model=model,
            messages=messages,
            extra_body={"enable_thinking": True},
            stream=True,
        )

        reasoning_parts = []
        answer_parts = []
        for chunk in completion:
            choices = getattr(chunk, "choices", None) or []
            if not choices:
                continue
            delta = getattr(choices[0], "delta", None)
            if not delta:
                continue

            reasoning_content = getattr(delta, "reasoning_content", None)
            if reasoning_content:
                reasoning_parts.append(reasoning_content)
            content = getattr(delta, "content", None)
            if content:
                answer_parts.append(content)

        answer_text = "".join(answer_parts).strip()
        if answer_text:
            return answer_text

        reasoning_text = "".join(reasoning_parts).strip()
        if reasoning_text:
            return f"【思考过程】\n{reasoning_text}"

        raise RuntimeError(f"千问 Chat Completions 未返回有效内容（model={model}）。")

    def _generate_with_responses_stream(self, model: str, messages: list[dict]):
        stream = self.client.responses.create(
            model=model,
            input=messages,
            extra_body={"enable_thinking": True},
            stream=True,
        )
        for event in stream:
            if getattr(event, "type", None) == "response.output_text.delta":
                delta = getattr(event, "delta", None)
                if delta:
                    yield delta

    def _generate_with_chat_completions_stream(self, model: str, messages: list[dict]):
        completion = self.client.chat.completions.create(
            model=model,
            messages=messages,
            extra_body={"enable_thinking": True},
            stream=True,
        )
        for chunk in completion:
            choices = getattr(chunk, "choices", None) or []
            if not choices:
                continue
            delta = getattr(choices[0], "delta", None)
            if not delta:
                continue
            content = getattr(delta, "content", None)
            if content:
                yield content
