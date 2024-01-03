#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Este script inicia procesos de Celery en el contenedor de Docker asociado a Taiga.

# Establece opciones de shell estrictas
set -euo pipefail

# Da permisos al usuario 'taiga' sobre el directorio /taiga-back después de montar volúmenes
echo Dando permisos a taiga:taiga
chown -R taiga:taiga /taiga-back

# Inicia los procesos de Celery
echo Iniciando Celery...
exec gosu taiga celery -A taiga.celery worker -B \
    --concurrency 4 \          # Número de procesos de Celery simultáneos
    -l INFO \                 # Nivel de registro de Celery (en este caso, INFO)
    "$@"