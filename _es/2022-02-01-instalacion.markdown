---
layout: post
title: Instalación
uuid: ef0ca80d-09b4-4be6-9539-b99d396b9626
lang:
- 7ef630a6-3c55-4b5d-b6eb-1c23cb9ea3f7
---

## Dependencias

* [Pandoc](https://pandoc.org/).  Realiza la conversión de Markdown
  a otros formatos.

* [Tectonic](https://tectonic-typesetting.github.io/).  Es el motor de
  generación de PDF que recomendamos para Pandoc.  En lugar de instalar
  la distribución de TeXLive completa, Tectonic solo descarga los
  paquetes necesarios para generar cada archivo.  También es utilizado
  internamente para generar los formatos de imposición y encuadernado.

* El programa `pdfinfo` provisto por
  [Poppler](https://poppler.freedesktop.org/). Solo es necesario si vas
  a generar PDFs, para descubrir la cantidad de páginas de cada archivo.
  Si sabés de una forma que no requiera Poppler para encontrar la
  cantidad de páginas de un PDF, por favor contactanos.

## Entorno listo para usar

Si estás usando Linux x86\_64, recomendamos instalar
[haini.sh](https://0xacab.org/sutty/haini.sh).  Realizará la instalación
de una distribución Alpine 3.13 en un subdirectorio, junto con gemas
pre-compiladas por <https://gems.sutty.nl/>.

Luego de seguir las instrucciones de instalación de `haini.sh`, ejecuta
este comando para instalar el resto de dependencias:

```bash
haini.sh apk add --no-cache pandoc tectonic poppler-utils
```

## Instalación manual

Instala las dependencias usando tu gestor de paquetes preferido.  Si
contienen versiones muy antiguas (en comparación a las que anuncian en
sus sitios), podrías estar perdiéndote características o compilaciones
rotas.  En ese caso deberías instalarlas por vías alternativas
(descargar el binario, compilar desde código fuente, etc.)

Recomendamos instalar [rbenv](https://github.com/rbenv/rbenv) y
[ruby-build](https://github.com/rbenv/ruby-build) para preparar un
entorno de desarrollo Ruby 2.7.

Algunas de las [gemas](https://rubygems.org/) necesitarán un compilador
y un rato de tu computadora.  Dependiendo de la distribución del sistema
operativo, también podrías necesitar instalar cabeceras de desarrollo.

### Con el gestor de paquetes Pacman

```bash
# Como usuario root
pacman -Sy base-devel
```

### Con el gestor de paquetes APT

```bash
# Como usuario root
apt install build-essential
```

