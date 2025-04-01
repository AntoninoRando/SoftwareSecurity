FROM python:3.9-slim

WORKDIR /app

COPY Project1_SSA24_correct.c /app

RUN pip install --no-cache-dir flawfinder

CMD ["flawfinder", "."]