
---

## Copias de seguridad

El proyecto PlasmaZone dispone de scripts para realizar y restaurar
copias de seguridad de WordPress y MariaDB mediante Docker Compose.

### 1. Realizar una copia de seguridad

Con los contenedores de WordPress y MariaDB funcionando, ejecutar
desde la raiz del proyecto:

```bash
./scripts/backup.sh
```

El script genera dos archivos dentro de `backups/`:

- `db_AAAAMMDD-HHMMSS.sql.gz`: copia de la base de datos MariaDB.
- `wp-content_AAAAMMDD-HHMMSS.tar.gz`: copia de los plugins,
  temas y archivos subidos a WordPress.

Ambos archivos utilizan la misma fecha y hora.

El script comprueba los archivos generados y conserva
las siete ultimas copias de cada tipo.

Para ver las copias disponibles:

```bash
ls -lh backups/
```

### 2. Restaurar una copia de seguridad

Primero consultar las copias disponibles:

```bash
./scripts/restore.sh
```

Despues ejecutar el script indicando la fecha de la copia:

```bash
./scripts/restore.sh AAAAMMDD-HHMMSS
```

Por ejemplo, para restaurar la copia utilizada en la practica:

```bash
./scripts/restore.sh 20261117-163120
```

El script comprueba los archivos y solicita confirmacion
escribiendo `SI`.

**Atencion:** la restauracion sobrescribe la base de datos
y sustituye `wp-content` por el contenido de la copia.
Se perderan los cambios posteriores a la fecha restaurada.

Durante la restauracion, WordPress y Nginx se detienen
temporalmente y vuelven a iniciarse al finalizar.

### 3. Copias automaticas con cron

En el equipo local se ha programado una copia automatica
los martes y miercoles a las 13:30.

La tarea se configura mediante:

```bash
crontab -e
```

El resultado de cada ejecucion se guarda en:

`backups/backup.log`

Para comprobar la programacion:

```bash
crontab -l
```

Las copias automaticas requieren que Kubuntu este encendido,
cron este activo y los contenedores necesarios funcionen.

### 4. Seguridad

La carpeta `backups/` esta excluida de Git mediante `.gitignore`.

Los scripts `backup.sh` y `restore.sh` se guardan en GitHub,
pero las copias de seguridad y las credenciales de `.env`
no deben subirse al repositorio.

Para reconstruir el sitio es necesario disponer del
repositorio, el archivo `.env` guardado de forma segura,
una copia SQL y la correspondiente copia de `wp-content`.
