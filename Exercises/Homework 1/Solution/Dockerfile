FROM python:3-alpine@sha256:144af7c1c157e735b9af2bc44857e2cc16f78c249e2f37b866f1a03803612c2b

WORKDIR /app

COPY Project1_SSA24_correct.c /app

RUN pip install --no-cache-dir flawfinder

CMD ["flawfinder", "."]