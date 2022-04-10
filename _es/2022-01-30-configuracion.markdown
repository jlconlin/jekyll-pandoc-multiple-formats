---
layout: post
title: Configuración
uuid: 6e1cae68-9b54-4f28-ae74-55e306b5fb3e
lang:
- c0e0b3d9-3945-4cdb-a29e-560a3cf818b7
---

## Habilitar el complemento

Agrega el complemento en el archivo `_config.yml` de Jekyll:

```yaml
plugins:
- jekyll-printing-press
```

## Configurar el complemento

La configuración específica se encuentra dentro de la "llave" `pandoc`
en el archivo `_config.yml`:

```yaml
pandoc:
  # La configuración empieza aquí
```

### Usar Pandoc para generar páginas web

Para reemplazar `kramdown` como el procesador de Markdown por defecto de
Jekyll:

```yaml
markdown: Pandoc
```

El contenido escrito en Markdown del sitio Jekyll será procesado primero
por Liquid (a menos que lo deshabilites) y luego generado como HTML5
utilizando el formato de salida de Pandoc correspondiente.

El formato de salida tiene opciones que puedes configurar más adelante.

### Formatos y opciones

Las opciones de Pandoc pueden ser configuradas en formato YAML en la
configuración de Jekyll.  Puedes usar _snake\_case_[^snake-case]
o _kebab-case_[^kebab-case] para nombrar las opciones.

[^snake-case]: Minúsculas y guión bajo para separar palabras.
[^kebab-case]: Minúsculas y guión medio para separar palabras.

Para más información sobre las opciones y sus valores posibles, puedes
consultar la [documentación de Pandoc (en
inglés)](https://pandoc.org/MANUAL.html#options).

Agrega la llave `options` al archivo de configuración.

```yaml
pandoc:
  options:
```

Luego, una llave para cada formato de salida.

```yaml
pandoc:
  options:
    html5:
    pdf:
    epub:
```

Cada formato contendrá opciones y sus valores.

```yaml
pandoc:
  options:
    html5:
      table-of-contents: true
      toc-depth: 3
    pdf:
      variable:
      - documentclass=book
      - papersize=a5
    epub: true
```

Si no es necesario agregar opciones a un formato, puedes activarlo
asignándole un valor `true` (verdadero, encendido), como en `epub` en el
ejemplo.

Algunas opciones no necesitan un valor por lo que también pueden
activarse con un valor `true`.  Otras necesitan un valor, como
`toc-depth` para `html5`, o aceptan una lista de valores, como
`variable` en `pdf`.

La lista de opciones y valores puede ser tan corta o tan larga como la
necesites.  Cualquier opción soportada por Pandoc es aceptada.

#### Opciones para la publicación del sitio

Cuando activas Pandoc para generar las páginas HTML, puedes cambiar sus
opciones con el formato `html5`.

```yaml
pandoc:
  options:
    html5:
      # Las opciones de páginas web van aquí
```

#### Opciones comunes

Para compartir opciones entre distintos formatos, puedes usar el formato
especial `common`.  Las opciones dentro de `common` están disponibles en
todos los formatos.

En este ejemplo, los tres formatos tienen un índice, pero sólo HTML5
produce uno que incluye los títulos de tercer nivel.

```yaml
pandoc:
  options:
    common:
      table-of-contents: true
    html5:
      toc-depth: 3
    pdf:
      variable:
      - documentclass=book
      - papersize=a5
    epub: true
```

#### Deshabilitar o cambiar opciones comunes

Si necesitas deshabilitar una opción en un formato específico, pero
mantenerla para los demás, cambia su valor a `false` (falso, apagado).

```yaml
pandoc:
  options:
    common:
      table-of-contents: true
    html5:
      toc-depth: 3
    pdf:
      variable:
      - documentclass=book
      - papersize=a5
    epub:
      table-of-contents: false
```

Ahora solo `html5` y `pdf` tienen índices y `epub` no.

El mismo funcionamiento aplica para cambiar un valor:

```yaml
pandoc:
  options:
    common:
      table-of-contents: true
      toc-depth: 3
    html5:
      toc-depth: 4
    pdf:
      variable:
      - documentclass=book
      - papersize=a5
    epub: true
```

Ahora todos los formatos tienen un índice con títulos de tercer nivel,
exceptuando `html5` que incluye los de cuarto nivel.
