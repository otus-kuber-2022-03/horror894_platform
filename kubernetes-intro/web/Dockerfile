FROM python:3

USER 1001:1001

WORKDIR /app

COPY index.html /app

ENTRYPOINT [ "python", "-m", "http.server", "8000"]
