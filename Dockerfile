FROM python:3.11

WORKDIR /app/backend

RUN apt-get update \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/backend

RUN pip install --no-cache-dir -r requirements.txt 

COPY . /app/backend

EXPOSE 8000
