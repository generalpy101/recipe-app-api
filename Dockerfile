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

# Here we are installing postgresql-client and
# other dependencies for psycopg2 build
# We remove them after we are done, to save space, virtual .tmp-build-deps
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ] ; then /py/bin/pip install -r /tmp/requirements.dev.txt ; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
    
ENV PATH="/py/bin:$PATH"

# Do not run as root
# No password so no login
USER django-user