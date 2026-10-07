# Decisión de CMS e imagen Docker

## Requisitos de WordPress

Según la documentación oficial de WordPress, para ejecutar WordPress se recomienda utilizar:

- PHP 8.3 o superior.
- MariaDB 10.11 o superior, o MySQL 8.0 o superior.
- Soporte para HTTPS.

## Imagen Docker elegida

La imagen que utilizaremos será:

`wordpress:7.1-php8.3-fpm`

### Diferencia entre Apache y FPM

La variante `-apache` incluye el servidor web Apache preparado para servir WordPress directamente.

La variante `-fpm` utiliza PHP-FPM para procesar PHP. Necesita un servidor web adicional, como Nginx o Apache, que se comunique con PHP-FPM mediante FastCGI.

### Significado de php8.3

`php8.3` indica que la imagen utiliza PHP 8.3 para ejecutar WordPress.

### Por qué no utilizamos latest

No utilizamos la etiqueta `latest` porque no fija una versión concreta. Si la imagen cambia en el futuro, el entorno podría comportarse de forma diferente.

Al especificar una versión concreta conseguimos un entorno más reproducible y controlado.

## Comprobaciones realizadas

Se ha descargado correctamente la imagen:

`wordpress:7.1-php8.3-fpm`

La versión de PHP comprobada es:

`PHP 8.3.35`

También se ha comprobado que están disponibles los siguientes módulos necesarios:

- gd
- imagick
- intl
- mysqli
- zip

Por tanto, la imagen seleccionada cumple los requisitos necesarios para continuar con la instalación de WordPress en las siguientes sesiones.
