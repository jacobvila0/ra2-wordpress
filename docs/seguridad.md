
# Sesión 12 — Seguridad del gestor

## 1. Objetivo

El objetivo de esta práctica es mejorar la seguridad de PlasmaZone, una web desarrollada con WordPress y desplegada mediante Docker, nginx, PHP-FPM y MariaDB.

Para ello, hemos realizado un diagnóstico inicial, aplicado medidas de seguridad y comprobado su funcionamiento.

## 2. Diagnóstico de seguridad: antes y después

| Comprobación | Antes | Después |
|---|---|---|
| Cabecera Server | nginx/1.30.6 | nginx, sin mostrar versión |
| /xmlrpc.php | 405 Method Not Allowed | 403 Forbidden |
| /wp-config.php | No comprobado | 403 Forbidden |
| PHP en uploads | Se ejecutaba PHP (resultado: 2) | 403 Forbidden |
| Edición de ficheros desde el panel | No comprobado | Desactivada |
| Límite de intentos de login | No comprobado | Bloqueo temporal de 5 minutos |

## 3. Medidas de seguridad aplicadas

### 3.1. Seguridad de nginx

Se ha modificado el archivo `nginx/default.conf` para:

- Ocultar la versión de nginx mediante `server_tokens off`.
- Bloquear el acceso a `xmlrpc.php`.
- Bloquear el acceso a `wp-config.php`.
- Impedir la ejecución de archivos PHP en `wp-content/uploads`.
- Incorporar las cabeceras `X-Content-Type-Options: nosniff` y `X-Frame-Options: SAMEORIGIN`.

Estas medidas reducen la exposición de información y protegen archivos y rutas sensibles.

### 3.2. Protección de archivos de WordPress

Se ha añadido la siguiente configuración al servicio WordPress de `docker-compose.yml`:

`define('DISALLOW_FILE_EDIT', true);`

De esta manera, los administradores no pueden modificar directamente los archivos de temas y plugins desde los editores integrados del panel.

### 3.3. Seguridad de usuarios

Se ha creado el usuario `editor-plasmazone` con el rol Editor para gestionar los contenidos sin utilizar continuamente la cuenta de administrador.

También se ha cambiado el nombre público del administrador a `PlasmaZone Admin`, manteniendo un nombre diferente para iniciar sesión.

### 3.4. Protección contra intentos de acceso

Se ha instalado el plugin Limit Login Attempts Reloaded para limitar los intentos fallidos de inicio de sesión.

Se ha comprobado que, después de varios intentos incorrectos, WordPress muestra un mensaje de bloqueo temporal de 5 minutos.

### 3.5. Actualizaciones

Se han aplicado las actualizaciones pendientes desde el panel de WordPress para mantener el gestor y sus componentes actualizados.

## 4. Resultados

Después de aplicar las medidas de seguridad:

- nginx deja de mostrar su número de versión.
- Las rutas sensibles configuradas devuelven 403 Forbidden.
- No se permite ejecutar archivos PHP en la carpeta de subidas.
- La edición directa de archivos desde WordPress está desactivada.
- Se dispone de una cuenta Editor para el trabajo diario.
- El inicio de sesión está protegido frente a intentos repetidos.

## 5. Conclusión

La práctica ha permitido comprobar la importancia de aplicar diferentes capas de seguridad a un gestor de contenidos.

Las medidas implementadas reducen determinados riesgos, aunque no garantizan una seguridad absoluta. Es necesario mantener las actualizaciones, utilizar contraseñas seguras y realizar copias de seguridad periódicamente.
