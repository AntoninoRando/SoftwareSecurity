FROM python:3-alpine@sha256:9b4929a72599b6c6389ece4ecbf415fd1355129f22bb92bb137eea098f05e975

WORKDIR /app

COPY Project1_SSA24_correct.c /app

RUN pip install --no-cache-dir flawfinder

CMD ["flawfinder", "."]