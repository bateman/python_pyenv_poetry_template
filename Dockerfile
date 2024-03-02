# Base image
FROM python:3.13-rc-slim-bookworm

# Label docker image
LABEL maintainer="Fabio Calefato <fcalefato@gmail.com>"
LABEL org.label-schema.license="MIT"

# Install dependencies
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files
COPY python_pyenv_poetry_template python_pyenv_poetry_template
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

# Run start script
ENTRYPOINT ["./entrypoint.sh"]
