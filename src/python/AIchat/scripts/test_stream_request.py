import json

import httpx


def main():
    url = "http://127.0.0.1:9000/api/ai/chat/stream"
    payload = {
        "user_id": 1,
        "session_id": "stream-test-session",
        "question": "请用三句话解释什么是二叉搜索树。",
        "model": "qwen3.6-plus",
    }

    print(f"POST {url}")
    print(f"payload: {json.dumps(payload, ensure_ascii=False)}")
    print("\n开始接收流式输出:\n")

    with httpx.stream("POST", url, json=payload, timeout=120.0) as response:
        response.raise_for_status()
        for chunk in response.iter_text():
            if chunk:
                print(chunk, end="", flush=True)

    print("\n\n流式请求完成。")


if __name__ == "__main__":
    main()
