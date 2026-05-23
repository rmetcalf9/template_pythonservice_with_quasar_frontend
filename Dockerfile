FROM python:3.11-bookworm

# -----------------------------
# saas_social microservice
# -----------------------------

MAINTAINER Robert Metcalf

# -----------------------------
# Environment
# -----------------------------
ARG PROJECT_NAME
ENV APIAPP_PROJECT_NAME=${PROJECT_NAME}

ENV APP_DIR=/app
ENV APIAPP_FRONTEND=/frontend
ENV APIAPP_FRONTEND_FRONTEND=/frontend

ENV APIAPP_APIURL=http://localhost:80/api
ENV APIAPP_APIDOCSURL=http://localhost:80/apidocs
ENV APIAPP_FRONTENDURL=http://localhost:80/frontend
ENV APIAPP_APIACCESSSECURITY='[]'

ENV APIAPP_DEFAULTMASTERTENANTJWTCOLLECTIONALLOWEDORIGINFIELD="http://localhost"

ENV APIAPP_PORT=80
ENV APIAPP_MODE=DOCKER

# Use venv for all python execution
ENV VENV_PATH=/venv
ENV PATH="/venv/bin:$PATH"

EXPOSE 80

# -----------------------------
# Copy nginx installer
# -----------------------------
COPY install-nginx-debian.sh /

# -----------------------------
# System deps + nginx + venv setup
# -----------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        python3-venv \
        build-essential \
        libffi-dev \
        libssl-dev \
        nginx \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    bash /install-nginx-debian.sh; \
    \
    mkdir -p ${APP_DIR} \
             ${APIAPP_FRONTEND_FRONTEND} \
             /var/log/uwsgi; \
    \
    python3 -m venv ${VENV_PATH}; \
    ${VENV_PATH}/bin/pip install --upgrade pip setuptools wheel; \
    ${VENV_PATH}/bin/pip install uwsgi; \
    \
    wget --ca-directory=/etc/ssl/certs \
        https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
        -O /rds-combined-ca-bundle.pem

# -----------------------------
# App code
# -----------------------------
COPY ./services/src ${APP_DIR}

RUN /venv/bin/pip install --no-cache-dir -r ${APP_DIR}/requirements.txt

COPY ./frontend/dist/pwa ${APIAPP_FRONTEND_FRONTEND}
COPY ./VERSION /VERSION
COPY ./services/run_app_docker.sh /run_app_docker.sh
COPY ./nginx_default.conf /etc/nginx/conf.d/default.conf
COPY ./uwsgi.ini /uwsgi.ini
COPY ./healthcheck.sh /healthcheck.sh

# -----------------------------
# Runtime config
# -----------------------------
STOPSIGNAL SIGTERM

CMD ["/run_app_docker.sh"]

HEALTHCHECK --interval=30s --timeout=3s \
  CMD /healthcheck.sh
