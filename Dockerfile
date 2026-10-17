# Образ приложения в один этап — отправная точка домашнего задания.
# <базовый образ> заменить базовым образом своего варианта.
# В таком виде сборка падает: драйверы баз компилируются из исходников,
# а компилятора и заголовков в образе нет. Задание — переписать файл в два этапа.
FROM python:3.11-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc6-dev default-libmysqlclient-dev libpq-dev pkg-config \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /venv
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# ================= ЭТАП ЗАПУСКА =================
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libmariadb3 libpq5 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /venv /venv
ENV PATH=/venv/bin:$PATH

WORKDIR /app
COPY app.py .

ARG VERSION=5.0
RUN echo "$VERSION" > /app/VERSION

ENV PYTHONDONTWRITEBYTECODE=1
STOPSIGNAL SIGINT
CMD ["python", "app.py"]
