
#!/usr/bin/env bash

# RA3 - Practica 2: Copias de seguridad de PlasmaZone

set -euo pipefail

# Ir a la raiz del repositorio
cd "$(dirname "$0")/.."

DESTINO="backups"
CONSERVAR=7
FECHA="$(date +%Y%m%d-%H%M%S)"

F_DB="$DESTINO/db_$FECHA.sql.gz"
F_WP="$DESTINO/wp-content_$FECHA.tar.gz"

# Borrar archivos incompletos si falla la copia
trap 'echo "ERROR: la copia no se ha completado." >&2; rm -f "$F_DB" "$F_WP"' ERR

mkdir -p "$DESTINO"

echo "== Copia de seguridad $FECHA =="

# 0. Comprobar los servicios de Docker
for servicio in db wordpress; do
    if ! docker compose ps --status running --services | grep -qx "$servicio"; then
        echo "ERROR: el servicio '$servicio' no esta en marcha." >&2
        echo "Ejecuta: docker compose up -d" >&2
        exit 1
    fi
done

# 1. Copiar la base de datos
echo "-> Volcando la base de datos..."

docker compose exec -T db sh -c '
    : "${WP_DB_USER:?falta WP_DB_USER}" "${WP_DB_NAME:?falta WP_DB_NAME}"
    exec mariadb-dump --single-transaction --no-tablespaces \
         -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"' \
    | gzip > "$F_DB"

# 2. Copiar los archivos de WordPress
echo "-> Empaquetando wp-content..."

docker compose exec -T wordpress \
    tar -czf - -C /var/www/html wp-content > "$F_WP"

# 3. Comprobar la integridad
gzip -t "$F_DB" "$F_WP"

[ "$(gunzip -c "$F_DB" | grep -c 'CREATE TABLE')" -gt 0 ] || {
    echo "ERROR: el volcado no contiene tablas" >&2
    exit 1
}

# 4. Conservar las ultimas siete copias de cada tipo
for patron in 'db_*.sql.gz' 'wp-content_*.tar.gz'; do
    ls -1t "$DESTINO"/$patron 2>/dev/null \
        | tail -n +"$((CONSERVAR + 1))" \
        | xargs -r rm -f --
done

echo "OK. Copia guardada:"
ls -lh "$F_DB" "$F_WP"

echo "Copias disponibles: $(ls -1 "$DESTINO"/db_*.sql.gz | wc -l) (se conservan $CONSERVAR)"
