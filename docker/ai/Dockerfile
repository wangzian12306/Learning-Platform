FROM python:3.13-slim
WORKDIR /app
COPY src/python/AIchat/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/python/AIchat/ .
EXPOSE 9000
CMD ["python", "run.py"]
