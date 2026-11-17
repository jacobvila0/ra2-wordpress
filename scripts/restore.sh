
#!/usr/bin/env bash

# RA3 - Practica 2: Restauracion de PlasmaZone

set -euo pipefail

# Ir a la raiz del proyecto
cd "$(dirname "$0")/.."

# Mostrar las copias disponibles si no indicamos fecha
if [ "$#" -eq 0 ]; then
    echo "== Copias disponibles =="

    for archivo in backups/db_*.sql.gz; do
        [ -f "$archivo" ] || continue

        fecha="${archivo#backups/db_}"
        fecha="${fecha%.sql.gz}"

        if [ -f "backups/wp-content_$fecha.tar.gz" ]; then
            echo "$fecha"
        fi
    done

    echo
    echo "Uso: ./scripts/restore.sh AAAAMMDD-HHMMSS"
    exit 0
fi

# Comprobar los argumentos
if [ "$#" -ne 1 ] || \
   [[ ! "$1" =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
    echo "ERROR: indica una fecha valida."
    exit 1
fi

FECHA="$1"
F_DB="backups/db_$FECHA.sql.gz"
F_WP="backups/wp-content_$FECHA.tar.gz"

# Comprobar que existen las dos copias
if [ ! -f "$F_DB" ] || [ ! -f "$F_WP" ]; then
    echo "ERROR: faltan archivos de la copia $FECHA"
    exit 1
fi

# Comprobar que los archivos comprimidos son validos
echo "Comprobando archivos..."
gzip -t "$F_DB" "$F_WP"

# Comprobar que existe el servicio de base de datos
if ! docker compose ps --status running --services | grep -qx db; then
    echo "ERROR: MariaDB no esta en marcha."
    exit 1
fi

# Localizar el volumen de WordPress
CONTENEDOR="$(docker compose ps -a -q wordpress)"

if [ -z "$CONTENEDOR" ]; then
    echo "ERROR: no se encuentra el contenedor WordPress."
    exit 1
fi

VOLUMEN="$(docker inspect --format \
    '{{range .Mounts}}{{if eq .Destination "/var/www/html"}}{{.Name}}{{end}}{{end}}' \
    "$CONTENEDOR")"

if [ -z "$VOLUMEN" ]; then
    echo "ERROR: no se encuentra el volumen de WordPress."
    exit 1
fi

echo
echo "== Restauracion de $FECHA =="
echo "Base de datos: $F_DB"
echo "Archivos: $F_WP"
echo "Volumen: $VOLUMEN"
echo
echo "ATENCION: se sustituiran los datos actuales."
read -r -p "Escribe SI para continuar: " RESPUESTA

if [ "$RESPUESTA" != "SI" ]; then
    echo "Restauracion cancelada."
    exit 0
fi

# Volver a arrancar los servicios al terminar
REINICIAR=0

recuperar_servicios() {
    if [ "$REINICIAR" -eq 1 ]; then
        docker compose up -d wordpress nginx
    fi
}

trap recuperar_servicios EXIT

# Detener el acceso a WordPress durante la restauracion
echo "Deteniendo WordPress y Nginx..."
REINICIAR=1
docker compose stop nginx wordpress

# Restaurar la base de datos
echo "Restaurando MariaDB..."

gzip -dc "$F_DB" | docker compose exec -T db sh -c \
    'exec mariadb -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"'

# Restaurar wp-content desde un contenedor temporal
echo "Restaurando wp-content..."

docker run --rm \
    -v "$VOLUMEN":/sitio \
    -v "$PWD/backups":/copias:ro \
    alpine sh -eu -c '
        TEMP="/sitio/.ra3_restore_tmp"
        rm -rf "$TEMP"
        mkdir -p "$TEMP"

        tar -xzf "/copias/wp-content_${1}.tar.gz" -C "$TEMP"
        test -d "$TEMP/wp-content"

        rm -rf /sitio/wp-content
        mv "$TEMP/wp-content" /sitio/wp-content
        rmdir "$TEMP"
    ' sh "$FECHA"

echo "Restauracion de archivos completada."
echo "Iniciando WordPress..."

docker compose up -d wordpress nginx
REINICIAR=0

echo "OK. Restauracion completada: $FECHA"
