# INFORME RA3 — Administración de gestores de contenidos

**Proyecto:** PlasmaZone  
**Asignatura:** Implantación de Aplicaciones Web  
**Ciclo:** 2.º ASIX  
**Práctica:** RA3 — Usuarios, perfiles y módulos  
**Entorno:** WordPress con Docker Compose en Kubuntu local  
**Rama de Git:** `ra3-admin`

---

## 1. Gestión de usuarios y perfiles

### 1.1. Preparación del entorno

Para esta práctica hemos utilizado la instalación de WordPress que ya teníamos funcionando en Docker.

Hemos creado la rama `ra3-admin` para separar el trabajo de administración del contenido realizado anteriormente.

También hemos incorporado WP-CLI mediante un servicio de Docker Compose y un script llamado `wp`. Esta herramienta nos permite administrar WordPress desde la terminal sin tener que hacerlo todo desde el navegador.

Comprobamos su funcionamiento con los comandos:

```bash
./wp core version
./wp user list
```

La versión de WordPress obtenida fue **7.1.4**.

### 1.2. Usuarios creados

Hemos creado diferentes usuarios para comprobar los permisos de los roles de WordPress.

| Usuario | Rol | Función |
|---|---|---|
| `jacoku-wp` | Administrador | Gestionar toda la web |
| `editor-plasmazone` | Editor | Usuario existente del proyecto |
| `coord.web` | Editor | Revisar y publicar contenidos |
| `profe.redes` | Autor | Crear y publicar entradas propias |
| `alumna.fct` | Colaborador | Redactar entradas para revisión |
| `familia.garcia` | Suscriptor | Acceder a su perfil |

Utilizamos el panel de administración y WP-CLI para crear las cuentas. Comprobamos que los usuarios tenían los roles correctos mediante:

```bash
./wp user list --fields=ID,user_login,roles
```

### 1.3. Pruebas de permisos

**Colaborador — `alumna.fct`**

Creamos una entrada llamada **«Mi primera semana en prácticas»**. El usuario podía redactarla, pero WordPress mostraba la opción «Enviar para revisión», en lugar de permitir la publicación directa.

**Editor — `coord.web`**

Accedimos con este usuario y publicamos la entrada que había creado `alumna.fct`. La entrada quedó publicada manteniendo como autora a la alumna. Esto demuestra que el Editor puede gestionar entradas de otros usuarios.

**Autor — `profe.redes`**

Creamos y publicamos la entrada **«La importancia de las redes informáticas»**. En el listado de entradas del Autor solo aparecían sus publicaciones, por lo que no disponía de la gestión de entradas ajenas que tiene el Editor.

**Suscriptor — `familia.garcia`**

Al iniciar sesión comprobamos que el menú de administración estaba muy limitado y permitía principalmente acceder al escritorio y modificar el perfil. No disponía de opciones para crear entradas ni gestionar plugins.

### 1.4. Creación de un rol personalizado

Creamos un rol llamado **Revisor**, partiendo de los permisos del Editor:

```bash
./wp role create revisor "Revisor" --clone=editor
```

Después retiramos las capacidades de eliminación de entradas y páginas, además de la gestión de categorías:

```bash
./wp cap remove revisor \
  delete_posts delete_others_posts \
  delete_published_posts delete_private_posts \
  delete_pages delete_others_pages \
  delete_published_pages delete_private_pages \
  manage_categories
```

También creamos el usuario `revisor.fp`, asociado al nuevo rol.

Para comprobar que no tenía permisos de borrado ejecutamos:

```bash
./wp cap list revisor | grep delete || echo "Sin capacidades de borrado"
```

El resultado fue:

```text
Sin capacidades de borrado
```

Esto confirma que retiramos las capacidades de eliminación del rol.

### 1.5. Seguridad del registro

Comprobamos las opciones de registro de usuarios mediante:

```bash
./wp option get users_can_register
./wp option get default_role
```

Los resultados fueron:

```text
0
subscriber
```

El valor `0` significa que el registro público está desactivado. Además, el rol predeterminado está configurado como Suscriptor, que tiene permisos limitados.

Estas configuraciones ayudan a evitar que los visitantes obtengan permisos elevados sin autorización.

---

## 2. Selección y administración de módulos

### 2.1. ¿Qué es un plugin?

Un plugin es un complemento que añade funcionalidades a WordPress sin necesidad de modificar directamente el código del sistema.

En PlasmaZone hemos utilizado plugins para gestionar formularios, avisos de cookies, seguridad y registros de actividad.

Consultamos los plugins mediante:

```bash
./wp plugin list
docker compose exec wordpress ls wp-content/plugins
```

Así verificamos tanto su estado dentro de WordPress como sus archivos en el contenedor.

### 2.2. R1 — Formulario que almacene mensajes

| Alternativa | Características |
|---|---|
| Contact Form 7 + Flamingo | Permite crear formularios y guardar los mensajes recibidos en WordPress |
| WPForms Lite | Permite crear formularios mediante una interfaz visual; el almacenamiento de entradas depende de sus funciones y versión |

**Elección: Contact Form 7 + Flamingo.**

Elegimos esta combinación porque Contact Form 7 ya estaba instalado y utilizado en la página Contacto de PlasmaZone. Solo necesitábamos añadir Flamingo para almacenar los mensajes.

Instalamos Flamingo con:

```bash
./wp plugin install flamingo --activate
```

Después modificamos el formulario y añadimos el campo obligatorio `ciclo`, con las opciones ASIR, DAW y SMR.

En la configuración adicional añadimos:

```text
skip_mail: on
```

Esta opción evita que Contact Form 7 intente enviar correos, ya que en esta práctica no hemos configurado un servidor SMTP.

Realizamos una prueba desde la página Contacto y comprobamos el almacenamiento del mensaje en **Flamingo → Mensajes entrantes**.

### 2.3. R2 — Aviso y consentimiento de cookies

Comparamos diferentes plugins utilizando:

```bash
./wp plugin search cookie --fields=name,slug,active_installs,rating,last_updated --per-page=6
```

Los resultados principales fueron:

| Plugin | Instalaciones activas | Valoración | Última actualización |
|---|---:|---:|---|
| Complianz | 1.000.000 | 94/100 | 04/11/2026 |
| CookieYes | 1.000.000 | 96/100 | 27/10/2026 |

**Elección: Complianz.**

Los dos plugins tenían una cantidad elevada de instalaciones, buenas valoraciones y actualizaciones recientes.

Elegimos Complianz porque dispone de un asistente que facilita la configuración del consentimiento de cookies y las opciones de privacidad.

Lo instalamos y configuramos para PlasmaZone, teniendo en cuenta la normativa europea de protección de datos.

Para comprobar su funcionamiento se debe verificar que el banner aparece a los visitantes nuevos, que permite aceptar o rechazar el consentimiento de forma equivalente y que ofrece acceso a la información sobre cookies.

La instalación del plugin, por sí sola, no garantiza el cumplimiento legal: también es necesario configurar correctamente las cookies y servicios que utiliza la web.

### 2.4. R3 — Registro de actividad

| Alternativa | Características |
|---|---|
| Simple History | Permite consultar un historial de acciones realizadas en WordPress |
| WP Activity Log | Ofrece un registro de actividad más detallado y diferentes opciones de seguimiento |

**Elección: Simple History.**

Elegimos Simple History porque cubre las necesidades básicas de la práctica y permite consultar actividades como los accesos de usuarios y los cambios realizados en el sitio.

Instalamos el plugin con:

```bash
./wp plugin install simple-history --activate
```

Después accedimos al historial de actividad desde el panel de WordPress para consultar los registros.

### 2.5. Limpieza de plugins

Al revisar los plugins instalados, encontramos que Akismet y Hello Dolly estaban inactivos y no se utilizaban en PlasmaZone.

Para mantener la instalación más limpia, ejecutamos:

```bash
./wp plugin delete akismet hello
```

Mantener únicamente los plugins necesarios ayuda a reducir el mantenimiento y los componentes innecesarios de la aplicación.

---

## 3. Conclusiones

Durante esta práctica hemos aprendido a gestionar usuarios, roles y permisos de WordPress, tanto desde el panel de administración como mediante WP-CLI.

También hemos creado un rol personalizado con permisos específicos y comprobado las diferencias entre Administrador, Editor, Autor, Colaborador y Suscriptor.

Por último, hemos seleccionado e instalado plugins para ampliar las funcionalidades de PlasmaZone: almacenamiento de formularios, consentimiento de cookies y registro de actividad.

La práctica nos ha ayudado a entender la importancia de aplicar permisos adecuados, mantener los plugins actualizados y utilizar únicamente los complementos necesarios.
