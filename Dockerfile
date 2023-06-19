FROM python:3.9-alpine3.13
LABEL maintainer="generalpy"

# Don't buffer output
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

EXPOSE 8000

# Default to production
# Will ovveride in docker-compose.yaml if needed
ARG DEV=false

# Multiple run commands mean multiple layers
# https://docs.docker.com/build/guide/layers/

# Remove /tmp to save space
# Light weight docker images are good
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ] ; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
    
ENV PATH="/py/bin:$PATH"

# Do not run as root
# No password so no login
USER django-user