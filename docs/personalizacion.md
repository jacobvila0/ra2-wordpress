
# Personalización del sitio — PlasmaZone

## 1. Tema activo

- **Tema:** Astra
- **Motivo de elección:** es un tema ligero, moderno y personalizable, adecuado para una web informativa sobre KDE Plasma y Kubuntu.

### Personalización realizada

- Configuración del título PlasmaZone.
- Incorporación de un logotipo relacionado con KDE.
- Personalización de la cabecera.
- Configuración del menú de navegación.
- Adaptación de la apariencia al estilo de KDE Plasma.

## 2. Plugin instalado

- **Nombre:** Contact Form 7
- **Versión:** 6.2.2
- **Última actualización:** 11 de octubre de 2026
- **Instalaciones activas:** pendiente de consultar en WordPress.

### ¿Por qué se ha instalado?

Se ha elegido Contact Form 7 para incorporar un formulario de contacto que permita a los visitantes enviar consultas y sugerencias relacionadas con KDE Plasma y Kubuntu.

El formulario está integrado en la página Contacto.

## 3. Estructura de contenidos

### Páginas
- Inicio
- Sobre el proyecto
  - Tecnologías (página hija)
- Contacto

### Categorías
- Novedades
- Tutoriales

### Entradas
1. ¿Qué es KDE Plasma y por qué destaca en Linux?
2. Cómo personalizar KDE Plasma paso a paso
3. Primeros pasos con Kubuntu: configuración inicial

### Menú principal
Inicio | Sobre el proyecto (Tecnologías) | Contacto

Se ha configurado Inicio como portada estática.

## 4. Biblioteca de medios

Se han incorporado imágenes relacionadas con KDE Plasma, Kubuntu y la personalización del escritorio.

Los archivos se almacenan en el volumen persistente de WordPress, dentro de:

/var/www/html/wp-content/uploads/2026/10/

## 5. Configuración de PHP

Se ha creado el archivo config/uploads.ini con los siguientes parámetros:

- upload_max_filesize = 64M
- post_max_size = 64M
- memory_limit = 256M

El archivo se monta en el contenedor de WordPress mediante docker-compose.yml.

Se ha comprobado mediante php -i que los tres valores se aplican correctamente.

## 6. Persistencia y Git

El código de configuración de Docker, nginx y PHP se almacena en GitHub.

El contenido de WordPress, las imágenes, los temas y los plugins instalados se mantienen en los volúmenes de Docker.
