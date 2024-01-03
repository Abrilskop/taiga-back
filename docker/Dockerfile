# Este Código Fuente está sujeto a los términos de la Licencia Pública de Mozilla
# (Mozilla Public License), v. 2.0. Si una copia de la MPL no fue distribuida con este
# archivo, puede obtener una en http://mozilla.org/MPL/2.0/.
#
# Derechos de autor (c) 2021-present Kaleidos Ventures SL

FROM python:3.11-slim
LABEL maintainer="support@taiga.io"

# Evitar solicitudes de configuración interactivas
ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# Utilizar un entorno virtual
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Obtener el código
COPY . /taiga-back
WORKDIR /taiga-back

# Obtener gosu para facilitar la transición de root
# https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.12

RUN set -eux; \
    apt-get update; \
    # instalar dependencias del sistema
    apt-get install -y \
       build-essential \
       gettext \
       # libpq5 necesario en tiempo de ejecución para psycopg2
       libpq5 \
       libpq-dev \
       git \
       net-tools \
       procps \
       wget; \
    # instalar gosu
    apt-get install -y --no-install-recommends ca-certificates wget; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    chmod +x /usr/local/bin/gosu; \
    # verificar la firma de gosu
    export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    # instalar dependencias de Taiga
    python -m pip install --upgrade pip; \
    python -m pip install wheel; \
    python -m pip install -r requirements.txt; \
    python -m pip install -r requirements-contribs.txt; \
    python manage.py compilemessages; \
    python manage.py collectstatic --no-input; \
    chmod +x docker/entrypoint.sh; \
    chmod +x docker/async_entrypoint.sh; \
    cp docker/config.py settings/config.py; \
    # crear grupo y usuario taiga para usarlo y dar permisos sobre el código (en entrypoint)
    groupadd --system taiga --gid=999; \
    useradd --system --no-create-home --gid taiga --uid=999 --shell=/bin/bash taiga; \
    mkdir -p /taiga-back/media/exports; \
    chown -R taiga:taiga /taiga-back; \
    # eliminar archivos y paquetes no necesarios
    apt-get purge -y \
       build-essential \
       gettext \
       git \
       libpq-dev \
       net-tools \
       procps \
       wget; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /root/.cache; \
    # limpiar Taiga
    rm requirements.txt; \
    rm requirements-contribs.txt; \
    find . -name '__pycache__' -exec rm -r '{}' +; \
    find . -name '*pyc' -exec rm -r '{}' +; \
    find . -name '*po' -exec rm -r '{}' +

ENV DJANGO_SETTINGS_MODULE=settings.config

EXPOSE 8000
ENTRYPOINT ["./docker/entrypoint.sh"]
