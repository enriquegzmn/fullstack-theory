# Teoría Detallada — Bloque 01: HTML y CSS (Semanas 1-2)

Este documento desarrolla a profundidad la teoría de las Semanas 1 y 2 del plan (HTML y CSS). Está escrito para una persona que **nunca ha programado**, así que cada concepto se explica desde cero, con analogías y ejemplos comentados línea por línea. En la versión actual del plan, los proyectos de este bloque se orientan directamente a la marca Denki Power Systems (ver `plan-denki-startup.md`).

---

## 1. ¿Cómo funciona una página web internamente?

Cuando escribes una dirección web en el navegador (por ejemplo `www.ejemplo.com`), ocurre lo siguiente:

1. El navegador pide el archivo HTML a un servidor.
2. El servidor responde enviando el código HTML como texto plano.
3. El navegador **parsea** (lee y analiza) ese texto y construye una estructura en memoria llamada **DOM** (lo veremos a fondo en el bloque de JavaScript).
4. El navegador busca archivos CSS enlazados y aplica esos estilos al DOM.
5. El navegador "pinta" (renderiza) el resultado final en la pantalla.
6. Si hay JavaScript, se ejecuta y puede modificar tanto el HTML como el CSS de forma dinámica.

Analogía: el HTML es el **esqueleto** de una casa (paredes, puertas, ventanas — la estructura). El CSS es la **decoración** (pintura, muebles, estilo). El JavaScript es la **electricidad y los mecanismos** (luces que se encienden, puertas automáticas).

---

## 2. HTML: Estructura y Semántica

### 2.1 ¿Qué es una etiqueta (tag)?
Una etiqueta es una palabra clave entre signos de menor/mayor que (`< >`) que le dice al navegador "esto que sigue es un párrafo", "esto es un título", etc. La mayoría de etiquetas vienen en pares:

```html
<p>Este es el contenido</p>
```
- `<p>` = etiqueta de apertura
- `Este es el contenido` = contenido del elemento
- `</p>` = etiqueta de cierre (nota la barra `/`)

Algunas etiquetas no tienen contenido ni cierre, se llaman **elementos vacíos**:
```html
<img src="foto.jpg">
<br>
<input type="text">
```

### 2.2 Anatomía de un documento HTML completo

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mi primera página</title>
</head>
<body>
  <h1>¡Hola, mundo!</h1>
</body>
</html>
```

Explicación detallada de **cada línea**:

- **`<!DOCTYPE html>`**: No es una etiqueta HTML como tal, es una declaración que le dice al navegador "interpreta este documento usando las reglas de HTML5". Sin esto, navegadores antiguos podían activar un "modo de compatibilidad" que rompe los estilos.
- **`<html lang="es">`**: Es el elemento raíz; todo el documento va dentro de él. El atributo `lang="es"` indica que el contenido está en español, lo cual ayuda a lectores de pantalla a pronunciar correctamente y a motores de búsqueda a clasificar el idioma.
- **`<head>`**: Contiene metadatos — información *sobre* la página que **no se muestra directamente** en el cuerpo visual.
- **`<meta charset="UTF-8">`**: Define la codificación de caracteres. UTF-8 permite mostrar correctamente letras con acentos, la "ñ", emojis, etc.
- **`<meta name="viewport" ...>`**: Crítica para que la página se vea bien en celulares. Le dice al navegador móvil: "usa el ancho real del dispositivo, no simules una pantalla de escritorio".
- **`<title>`**: El texto que aparece en la pestaña del navegador y en resultados de Google.
- **`<body>`**: Aquí va **todo el contenido visible**: textos, imágenes, botones, formularios, etc.

### 2.3 Etiquetas de texto

```html
<h1>Título de nivel 1 (el más importante)</h1>
<h2>Título de nivel 2</h2>
<h3>Título de nivel 3</h3>

<p>Un párrafo de texto normal. Los navegadores agregan automáticamente espacio antes y después.</p>

<strong>Texto importante (negrita)</strong>
<em>Texto enfatizado (cursiva)</em>

<blockquote>Una cita textual de otra fuente.</blockquote>

<code>const x = 5;</code>
<pre>
  Este texto respeta
  los    espacios   y
  saltos de línea originales
</pre>
```

**Jerarquía de encabezados**: se recomienda usar **solo un `<h1>` por página**, y luego `h2`/`h3` en orden lógico, como el índice de un libro. Esto ayuda a motores de búsqueda y lectores de pantalla a entender la estructura.

**`<strong>`/`<em>` vs `<b>`/`<i>`**: `<b>`/`<i>` son puramente visuales. `<strong>`/`<em>` tienen significado semántico: le dicen a tecnologías de accesibilidad que ese texto es importante, no solo que "se ve diferente".

### 2.4 Enlaces

```html
<a href="https://www.google.com">Ir a Google</a>
<a href="https://www.google.com" target="_blank" rel="noopener noreferrer">Nueva pestaña</a>
<a href="/sobre-mi.html">Página interna</a>
<a href="#contacto">Ir a sección (misma página)</a>
<a href="mailto:correo@ejemplo.com">Enviar correo</a>
```

`href` define el destino. `target="_blank"` abre en pestaña nueva (se recomienda agregar `rel="noopener noreferrer"` por seguridad). Los enlaces con `#` apuntan a un elemento con ese `id` en la misma página.

### 2.5 Imágenes

```html
<img src="logo.png" alt="Logo de la empresa Denki" width="200" height="100">
```

- `src`: ruta del archivo (local o URL completa).
- `alt`: texto alternativo, leído por lectores de pantalla y mostrado si la imagen no carga. **Nunca debe omitirse**.
- `width`/`height`: reservan el espacio antes de que cargue la imagen, evitando que el contenido "salte" (layout shift).

Formatos: **JPG** (fotografías, sin transparencia), **PNG** (con transparencia, ideal para logos), **WebP** (moderno, más liviano), **SVG** (vectorial, nítido en cualquier tamaño, ideal para íconos).

### 2.6 Listas

```html
<ul>
  <li>Manzana</li>
  <li>Plátano</li>
</ul>

<ol>
  <li>Primer paso</li>
  <li>Segundo paso</li>
</ol>

<dl>
  <dt>HTML</dt>
  <dd>Lenguaje de marcado para estructurar contenido.</dd>
</dl>
```

### 2.7 Tablas

Las tablas deben usarse **solo para datos tabulares**, nunca para maquetar el layout de una página.

```html
<table>
  <thead>
    <tr><th>Producto</th><th>Precio</th></tr>
  </thead>
  <tbody>
    <tr><td>Sensor BMP280</td><td>$120</td></tr>
  </tbody>
  <tfoot>
    <tr><td colspan="2">Total: 1</td></tr>
  </tfoot>
</table>
```
`thead`/`tbody`/`tfoot` organizan encabezado, cuerpo y pie. `colspan` hace que una celda ocupe varias columnas.

### 2.8 HTML Semántico

```html
<header><!-- logo, navegación principal --></header>
<nav><!-- menú de navegación --></nav>
<main>
  <section>
    <article><!-- contenido independiente, como un post de blog --></article>
  </section>
  <aside><!-- contenido relacionado/secundario --></aside>
</main>
<footer><!-- derechos de autor, contacto --></footer>
```

**Por qué importa**: (1) Accesibilidad — lectores de pantalla pueden saltar directo a `<nav>` o `<main>`. (2) SEO — Google entiende mejor la estructura. (3) Mantenibilidad — el código se entiende más rápido que con `<div>` genéricos.

### 2.9 Atributos globales

```html
<div class="tarjeta destacada" id="producto-1" data-categoria="sensores" title="Info extra">
```
- `class`: agrupa elementos para CSS/JS; un elemento puede tener varias clases.
- `id`: identificador único en toda la página.
- `data-*`: datos personalizados, leíbles después con JavaScript (`elemento.dataset.categoria`).
- `title`: tooltip al pasar el mouse.

### 2.10 Formularios en profundidad

```html
<form action="/procesar" method="POST">
  <label for="nombre">Nombre completo:</label>
  <input type="text" id="nombre" name="nombre" required minlength="3">

  <label for="correo">Correo:</label>
  <input type="email" id="correo" name="correo" required>

  <label for="password">Contraseña:</label>
  <input type="password" id="password" name="password" required pattern=".{8,}" title="Mínimo 8 caracteres">

  <label for="pais">País:</label>
  <select id="pais" name="pais">
    <option value="">-- Selecciona --</option>
    <option value="mx">México</option>
  </select>

  <fieldset>
    <legend>Género</legend>
    <input type="radio" id="masc" name="genero" value="masculino">
    <label for="masc">Masculino</label>
  </fieldset>

  <textarea id="mensaje" name="mensaje" rows="4" maxlength="500"></textarea>

  <input type="checkbox" id="terminos" name="terminos" required>
  <label for="terminos">Acepto los términos</label>

  <button type="submit">Enviar</button>
</form>
```

**Conceptos clave:**
- `action`/`method`: a dónde y cómo se envían los datos (`GET` visible en URL, `POST` oculto en el cuerpo).
- **`label` + `for`/`id`**: deben coincidir; obligatorio para accesibilidad y para que el clic en el texto enfoque el campo.
- **`name`**: el nombre con el que el dato viaja al servidor (distinto del `id`, que es para CSS/JS).
- **`required`/`minlength`/`maxlength`/`pattern`/`min`/`max`**: validaciones nativas del navegador, sin necesidad de JavaScript.

Tipos de `input` más comunes: `text`, `email` (valida formato), `password` (oculta texto), `number`, `date` (calendario nativo), `checkbox`, `radio`, `file`, `range` (slider), `color`.

---

## 3. CSS: Estilos y Layout

### 3.1 ¿Qué es CSS?

CSS separa **estructura** (HTML) de **presentación** (CSS): defines una regla una vez y se aplica a todos los elementos que coincidan, en lugar de mezclar estilos directamente en cada etiqueta HTML.

### 3.2 Las tres formas de aplicar CSS

```html
<!-- En línea: solo afecta a ese elemento -->
<p style="color: red;">Texto en rojo</p>

<!-- Interno: dentro de <style> en el <head> -->
<style> p { color: red; } </style>

<!-- Externo (recomendado): archivo .css separado -->
<link rel="stylesheet" href="estilos.css">
```

La forma externa es la recomendada en proyectos reales: separa contenido de presentación y permite reutilizar el mismo archivo en varias páginas.

### 3.3 Sintaxis de una regla CSS

```css
selector {
  propiedad: valor;
}
```
```css
h1 { color: navy; font-size: 32px; text-align: center; }
```

### 3.4 Tipos de selectores

```css
p { color: gray; }                  /* por etiqueta, afecta a todos */
.destacado { font-weight: bold; }    /* por clase */
#titulo-principal { font-size: 40px; } /* por id, único en la página */
nav a { text-decoration: none; }      /* descendiente: <a> dentro de <nav> */
ul > li { margin-bottom: 8px; }        /* hijo directo */
input[type="text"] { border: 1px solid gray; } /* por atributo */

a:hover { color: orange; }       /* pseudo-clase: mouse encima */
input:focus { border-color: blue; } /* pseudo-clase: campo enfocado */
li:first-child { color: red; }    /* primer elemento */
li:nth-child(2) { color: green; } /* elemento específico */

p::before { content: "→ "; }      /* pseudo-elemento: contenido virtual antes */

h1, h2, h3 { font-family: sans-serif; } /* múltiples selectores */
```

### 3.5 La cascada y la especificidad

Orden de especificidad (menor a mayor): selector por etiqueta → clase/atributo/pseudo-clase → id → estilo en línea → `!important` (se recomienda **evitar** `!important`, rompe la cascada natural).

Si dos reglas tienen la misma especificidad, **gana la escrita más abajo** en el archivo. Ejemplo:
```css
p { color: black; }
.aviso { color: red; }
#mensaje { color: blue; }
```
```html
<p id="mensaje" class="aviso">Texto</p>
```
Resultado: **azul**, porque el id tiene mayor especificidad que la clase y la etiqueta, sin importar el orden de escritura.

### 3.6 El Modelo de Caja (Box Model)

Todo elemento HTML ocupa una caja rectangular invisible, de adentro hacia afuera: **content** (contenido) → **padding** (espacio interno) → **border** (borde) → **margin** (espacio externo).

```css
.caja {
  width: 200px;
  padding: 20px;
  border: 2px solid black;
  margin: 10px;
}
```

**Problema clásico**: por defecto, `width: 200px` se refiere solo al contenido. Si agregas padding y border, el ancho REAL visible termina siendo mayor (200 + 20+20 padding + 2+2 border = 244px), no 200px como uno esperaría.

**Solución universal**, recomendada al inicio de cualquier proyecto:
```css
* { box-sizing: border-box; }
```
Con esto, el padding y border se incluyen **dentro** del `width` declarado, haciendo los cálculos predecibles.

**Colapso de márgenes**: cuando dos elementos en bloque están uno encima del otro, el espacio entre ellos no es la suma de sus márgenes, sino **el mayor de los dos**. Esto confunde a muchos principiantes la primera vez que lo encuentran.

### 3.7 Unidades de medida

- `px`: tamaño fijo, no se adapta.
- `%`: relativo al elemento padre.
- `rem`: relativo al tamaño de fuente raíz (normalmente 16px), **la más recomendada para tipografía y espaciados** porque escala con la configuración de accesibilidad del usuario.
- `em`: relativo al tamaño de fuente del padre (puede acumularse de forma impredecible).
- `vh`/`vw`: porcentaje del alto/ancho visible de la pantalla, útil para secciones que ocupan toda la pantalla (como un "hero" de landing page).

### 3.8 Colores en CSS

```css
color: red;                    /* nombre predefinido */
color: #FF0000;                 /* hexadecimal: RR GG BB */
color: rgb(255, 0, 0);           /* RGB de 0 a 255 */
color: rgba(255, 0, 0, 0.5);      /* RGB + transparencia (0=invisible, 1=opaco) */
color: hsl(0, 100%, 50%);          /* matiz, saturación, luminosidad */
```

### 3.9 Tipografía

```css
body {
  font-family: 'Helvetica Neue', Arial, sans-serif; /* lista de respaldo (fallback) */
  font-size: 16px;
  font-weight: 400;     /* 400=normal, 700=negrita */
  line-height: 1.5;      /* espacio entre líneas */
  text-align: center;
  text-transform: uppercase;
}
```
El navegador usa la primera fuente disponible de la lista; si no existe en el dispositivo, prueba la siguiente.

### 3.10 Display: comportamiento en el flujo

- `display: block`: ocupa todo el ancho, genera salto de línea (`div`, `p`, `h1`).
- `display: inline`: ocupa solo el espacio necesario, no respeta width/height (`span`, `a`).
- `display: inline-block`: como inline pero sí respeta width/height.
- `display: none`: el elemento desaparece, no ocupa espacio.

### 3.11 Flexbox: layouts en una dimensión

```css
.contenedor {
  display: flex;
  flex-direction: row;             /* row | column */
  justify-content: space-between;   /* distribución en el eje principal */
  align-items: center;               /* alineación en el eje cruzado */
  flex-wrap: wrap;
  gap: 16px;
}
```

**`justify-content`**: `flex-start`/`flex-end` (inicio/fin), `center`, `space-between` (extremos pegados, resto distribuido), `space-around`, `space-evenly`.
**`align-items`**: `stretch` (por defecto), `flex-start`/`flex-end`, `center`.

```css
.item { flex: 1; } /* atajo para que cada hijo ocupe una parte igual del espacio disponible */
```

Centrado perfecto, caso de uso muy común:
```css
.contenedor { display: flex; justify-content: center; align-items: center; height: 100vh; }
```

### 3.12 CSS Grid: layouts en dos dimensiones

```css
.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr); /* 3 columnas iguales */
  gap: 20px;
}
```
`fr` significa "fracción" del espacio disponible. Grid responsivo automático, sin media queries, muy usado en catálogos:
```css
.catalogo {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 20px;
}
```
Crea tantas columnas de mínimo 220px como quepan, repartiendo el espacio sobrante equitativamente.

### 3.13 Posicionamiento

- `static`: comportamiento normal (por defecto).
- `relative`: se desplaza respecto a su posición original, pero sigue ocupando su espacio.
- `absolute`: se posiciona respecto al ancestro posicionado más cercano (requiere un padre con `relative`), sale del flujo normal.
- `fixed`: se posiciona respecto a la ventana del navegador, no se mueve con el scroll.
- `sticky`: relative hasta cierto punto del scroll, luego se "pega" como fixed.

### 3.14 Diseño responsivo (Media Queries)

```css
.contenedor { display: flex; flex-direction: column; padding: 16px; } /* mobile por defecto */

@media (min-width: 768px) {
  .contenedor { flex-direction: row; padding: 32px; }
}
```

**Mobile-first**: escribir primero los estilos para pantallas pequeñas (sin media query), luego usar `min-width` para ir agregando estilos a medida que la pantalla crece. Es el enfoque recomendado actualmente.

### 3.15 Transiciones y animaciones

```css
.boton {
  transition: background-color 0.3s ease, transform 0.2s ease;
}
.boton:hover { background-color: #d4860c; transform: scale(1.05); }
```
`transition` anima el cambio entre dos estados durante el tiempo especificado.

```css
@keyframes aparecer {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.tarjeta { animation: aparecer 0.5s ease forwards; }
```
`@keyframes` define una secuencia de estados; `animation` la aplica controlando duración y comportamiento.

### 3.16 Variables CSS (Custom Properties)

```css
:root {
  --color-primario: #B8720A;
  --espaciado-base: 16px;
}
.boton { background-color: var(--color-primario); padding: var(--espaciado-base); }
```
Definir variables en `:root` las hace disponibles en toda la hoja de estilos, permitiendo cambiar el color principal de todo un sitio modificando una sola línea. Es la base técnica del modo claro/oscuro.

### 3.17 Metodología BEM

```html
<div class="tarjeta-producto">
  <img class="tarjeta-producto__imagen">
  <button class="tarjeta-producto__boton tarjeta-producto__boton--destacado">Comprar</button>
</div>
```
Block (`tarjeta-producto`), Element (`__imagen`, separado con doble guion bajo), Modifier (`--destacado`, separado con doble guion). Evita conflictos de nombres y hace evidente a qué componente pertenece cada clase.

### 3.18 Tailwind CSS (framework utility-first)

```html
<button class="bg-amber-600 text-white px-4 py-2 rounded-lg hover:bg-amber-700 transition">
  Comprar
</button>
```
Ofrece clases utilitarias predefinidas (una propiedad cada una) directamente en el HTML, en vez de escribir CSS propio. Ventaja: desarrollo más rápido y consistente. Desventaja: el HTML se ve más cargado. Muy demandado en el mercado laboral actual.

---

## Imágenes de referencia para los proyectos de este bloque

**Proyecto #1 — Landing Page Responsiva**: basada directamente en la estructura real de **denkienergy.com** (ver sección 5, "Proyecto guiado paso a paso"): header con navegación, hero con datos destacados, sección de problema (tarjetas), beneficios numerados, proceso en 3 pasos, casos de uso, testimonios, FAQ con acordeón nativo, formulario de contacto y footer — todo perfectamente adaptado a móvil.

**Proyecto #2 — Portafolio Personal**: sitio de una sola página con secciones claras (sobre mí, habilidades, proyectos en tarjetas, contacto), diseño limpio y profesional, construido con Tailwind CSS.

(Ver las imágenes de referencia mostradas en la conversación para ejemplos visuales reales de landing pages y portafolios de desarrolladores.)

---

## 4. Estructura de archivos del proyecto: denki-landing

Hasta ahora la teoría cubrió etiquetas y reglas sueltas; falta un paso necesario antes de empezar a construir: **cómo organizar los archivos** del proyecto real de la landing page de Denki en carpetas, no solo escribir HTML/CSS en un único archivo de prueba.

```
denki-landing/
├── index.html
├── css/
│   └── estilos.css
├── img/
│   ├── logo-denki.svg
│   └── (imágenes del hero, características, etc.)
├── .gitignore
└── README.md
```

**Por qué esta organización, y no otra:**
- **`index.html` en la raíz**: es el nombre de archivo que cualquier hosting estático (Netlify/Vercel, visto en el Bloque 07) busca automáticamente al servir un sitio — si el archivo principal tuviera otro nombre o estuviera en una subcarpeta, el sitio no cargaría correctamente sin configuración adicional.
- **`css/estilos.css`**: el archivo CSS externo (sección 3.2 de este documento) enlazado con `<link rel="stylesheet" href="css/estilos.css">` dentro del `<head>`. Se separa en su propia carpeta para no mezclar tipos de archivo distintos en la raíz del proyecto, algo que se vuelve más importante a medida que el sitio crece más allá de una sola página.
- **`img/`**: centraliza los recursos visuales (logo, imágenes de cada sección), evitando rutas relativas confusas como `../../imagenes/cosa.png` dispersas por el código.
- **`.gitignore`**: aunque un proyecto HTML/CSS puro casi no genera archivos que deban excluirse de Git, conviene tenerlo desde el primer commit (por ejemplo, para excluir `.DS_Store` en macOS) — es el mismo hábito que se refuerza con más peso en el Bloque 07 (Despliegue), donde si se omite en un proyecto con dependencias, sí puede causar problemas reales.
- **`README.md`**: descripción del proyecto, capturas de pantalla y enlace en vivo una vez desplegado — el mismo estándar de documentación que pide el checklist de producción del Bloque 07, aplicado aquí desde el inicio del curso en vez de agregarse después como ocurrencia tardía.

**Cómo enlazar los archivos correctamente:**
```html
<!-- dentro de index.html -->
<head>
  <link rel="stylesheet" href="css/estilos.css">
</head>
<body>
  <img src="img/logo-denki.svg" alt="Logo Denki Power Systems">
</body>
```
Nota que las rutas (`css/estilos.css`, `img/logo-denki.svg`) son **relativas** a la ubicación de `index.html`: como `index.html` vive en la raíz del proyecto, basta con indicar la subcarpeta sin necesidad de `./` al inicio (aunque escribirlo explícitamente, `./css/estilos.css`, también es válido y a veces preferido por claridad).

A medida que el proyecto crezca (por ejemplo, si la landing necesita una segunda página como `precios.html`), esta misma estructura se mantiene: el archivo nuevo se agrega en la raíz junto a `index.html`, y ambas páginas comparten el mismo `css/estilos.css`, evitando duplicar estilos.

---

## 5. Proyecto guiado paso a paso: réplica de denkienergy.com

El proyecto de este bloque deja de ser una landing genérica y se basa directamente en la estructura real de **https://www.denkienergy.com/**, un sitio de una empresa del mismo sector (medición energética IoT) que sirve como referencia casi perfecta para Denki Power Systems. A continuación se desglosa sección por sección, en el orden exacto en que aparecen en el sitio real, con la etiqueta semántica correspondiente y el paso a paso para construir cada una usando solo HTML y CSS (sin JavaScript — incluso el acordeón de preguntas frecuentes se logra con HTML/CSS puro, como se ve en el Paso 8).

### Paso 0 — Preparar la estructura de archivos
Antes de escribir contenido, crea la estructura de la sección 4 (`index.html`, `css/estilos.css`, `img/`), y deja el esqueleto base del documento (sección 2.2 de este bloque: `<!DOCTYPE html>`, `<head>` con `meta charset`/`viewport`/`title`, `<body>` vacío).

### Paso 1 — Header y navegación

El sitio real tiene un header fijo con el logo a la izquierda y enlaces de navegación a la derecha, más un botón de "Contacto" destacado.

```html
<header>
  <a href="#" class="logo">denki</a>
  <nav>
    <a href="#soluciones">Soluciones</a>
    <a href="#como-funciona">Cómo funciona</a>
    <a href="#casos-de-uso">Casos de uso</a>
    <a href="#faq">FAQ</a>
  </nav>
  <a href="#contacto" class="boton-cta">Contacto</a>
</header>
```
**CSS:** usa Flexbox (sección 3.11) con `justify-content: space-between` para distribuir logo/nav/botón, y `position: sticky; top: 0;` (sección 3.13) para que el header se mantenge visible al hacer scroll, como en el sitio original.

### Paso 2 — Hero (sección principal)

El hero real tiene una etiqueta pequeña ("Medición energética IoT"), un `<h1>` de dos líneas, un párrafo de propuesta de valor, dos botones (uno principal, uno secundario), y 3 datos destacados en línea (100% / IoT / 360°).

```html
<section class="hero">
  <p class="etiqueta">Medición energética IoT</p>
  <h1>Controla el consumo energético de tu empresa en tiempo real.</h1>
  <p>Instalamos dispositivos IoT que miden, analizan y reportan el uso energético de tu planta o empresa.</p>
  <div class="botones-hero">
    <a href="#contacto" class="boton-cta">Ponte en contacto con nosotros</a>
    <a href="#como-funciona" class="boton-secundario">Ver cómo funciona</a>
  </div>
  <div class="datos-destacados">
    <div><strong>100%</strong><span>Proyectos a medida</span></div>
    <div><strong>IoT</strong><span>Medición en tiempo real</span></div>
    <div><strong>360°</strong><span>Cobertura energética</span></div>
  </div>
</section>
```
**CSS:** los "datos destacados" se acomodan con Flexbox (`display: flex; gap: 32px;`), y los botones también con Flexbox en fila, pasando a columna en móvil (media query, sección 3.14) para que no se vean apretados en pantallas pequeñas.

### Paso 3 — Sección "El problema" (tarjetas con ícono)

4 tarjetas con un emoji/ícono, título y descripción — exactamente el caso de uso de CSS Grid responsivo visto en la sección 3.12 de este bloque.

```html
<section id="problema">
  <p class="etiqueta">El problema</p>
  <h2>La mayoría de empresas opera sin visibilidad energética real</h2>
  <div class="grid-tarjetas">
    <article class="tarjeta">
      <span class="icono">⚡</span>
      <h3>Incumplimiento del código de red</h3>
      <p>Tu fábrica recibe multas porque no puedes demostrar con datos que cumples los requisitos de calidad de energía.</p>
    </article>
    <!-- repetir <article> para las otras 3 tarjetas: "Consumo invisible", "Medidores obsoletos", "Datos dispersos" -->
  </div>
</section>
```
```css
.grid-tarjetas {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 24px;
}
```

### Paso 4 — Sección "Beneficios" (lista numerada)

6 beneficios numerados (01 a 06), cada uno con número, título y descripción — misma técnica de Grid que el Paso 3, pero mostrando el número con un pseudo-elemento o simplemente como texto grande.

```html
<section id="soluciones">
  <p class="etiqueta">Beneficios</p>
  <h2>Todo lo que obtienes con Denki Power Systems</h2>
  <div class="grid-tarjetas">
    <article class="beneficio">
      <span class="numero">01</span>
      <h3>Medición continua en tiempo real</h3>
      <p>Nuestros dispositivos IoT registran el consumo eléctrico segundo a segundo.</p>
    </article>
    <!-- repetir hasta el 06 -->
  </div>
</section>
```

### Paso 5 — Sección "Proceso" (3 pasos)

3 pasos numerados en fila (o columna en móvil), cada uno con número, título, descripción y una línea de detalle adicional en texto más pequeño.

```html
<section id="como-funciona">
  <p class="etiqueta">Proceso</p>
  <h2>De cero a monitoreo total en tres pasos</h2>
  <div class="pasos">
    <article class="paso">
      <span class="numero">01</span>
      <h3>Diagnóstico y diseño</h3>
      <p>Estudio de tu instalación eléctrica para definir los puntos de medición necesarios.</p>
      <small>Estudio energético + plano de instalación + propuesta técnica</small>
    </article>
    <!-- repetir para "Instalación de dispositivos IoT" y "Monitoreo desde la plataforma" -->
  </div>
</section>
```
**CSS:** `.pasos` con Flexbox en fila (`gap` entre cada paso), igual que el Paso 2, colapsando a columna en móvil.

### Paso 6 — Casos de uso (2 columnas con "El reto / La solución / Resultado")

Cada caso de uso tiene una etiqueta de categoría, título, y 3 subsecciones internas (el reto, la solución, el resultado) — buen ejercicio de jerarquía de encabezados (sección 2.3: `h2` para la sección, `h3` para cada caso, y un `h4` o `strong` para "El reto"/"La solución"/"Resultado" dentro de cada caso).

```html
<section id="casos-de-uso">
  <p class="etiqueta">Casos de uso</p>
  <h2>Cómo lo han resuelto otras empresas</h2>
  <div class="grid-casos">
    <article class="caso">
      <p class="categoria">Manufactura</p>
      <h3>Cumplimiento del código de red en planta industrial</h3>
      <h4>El reto</h4>
      <p>Una planta recibía penalizaciones de su proveedor eléctrico sin tener datos para refutar los cargos.</p>
      <h4>La solución</h4>
      <p>Instalamos medidores de calidad de energía en los puntos de conexión a la red.</p>
      <h4>Resultado</h4>
      <p>Visibilidad total del perfil eléctrico + evidencia verificable para disputar cargos.</p>
    </article>
    <!-- repetir para el segundo caso de uso, "Multi-planta" -->
  </div>
</section>
```

### Paso 7 — Testimonios

3 tarjetas de testimonio con cita, inicial en un círculo (avatar simple sin imagen), nombre y cargo — buen ejercicio de `border-radius: 50%` (visto en el Bloque sobre CSS) para simular el avatar circular con solo una letra.

```html
<section id="testimonios">
  <p class="etiqueta">Testimonios</p>
  <h2>Empresas que ya tienen visibilidad de su energía</h2>
  <div class="grid-tarjetas">
    <blockquote class="testimonio">
      <p>Antes del sistema de Denki, nuestros reportes de consumo eran manuales y llegaban con semanas de retraso.</p>
      <footer>
        <span class="avatar">R</span>
        <cite>Roberto A. — Director de Operaciones</cite>
      </footer>
    </blockquote>
    <!-- repetir para los otros 2 testimonios -->
  </div>
</section>
```
Nota el uso correcto de `<blockquote>`/`<cite>` (sección 2.3), apropiado semánticamente para citas atribuidas a una persona — más correcto que usar `<div>` genéricos para todo.

### Paso 8 — FAQ con acordeón (HTML/CSS puro, sin JavaScript)

El sitio real tiene preguntas que se expanden al hacer clic. Esto se logra sin JavaScript usando las etiquetas nativas `<details>`/`<summary>`:

```html
<section id="faq">
  <p class="etiqueta">FAQ</p>
  <h2>Preguntas frecuentes</h2>
  <details>
    <summary>¿Cuánto tiempo tarda la instalación?</summary>
    <p>El tiempo varía según el número de puntos de medición, pero la mayoría de instalaciones se completan en 1-2 semanas.</p>
  </details>
  <details>
    <summary>¿Necesito cambiar mi infraestructura eléctrica existente?</summary>
    <p>En la mayoría de los casos no, nuestros dispositivos se instalan de forma no invasiva.</p>
  </details>
  <!-- repetir para el resto de preguntas -->
</section>
```
`<details>` y `<summary>` son etiquetas HTML nativas que crean un acordeón funcional (clic para expandir/contraer) sin una sola línea de JavaScript — el navegador maneja el comportamiento de abrir/cerrar automáticamente. Con CSS se puede personalizar la apariencia de la flecha y el espaciado, pero la funcionalidad ya viene incluida.

### Paso 9 — Formulario de contacto

Aplica directamente la sección 2.10 de este bloque (formularios en profundidad): nombre, empresa, correo, mensaje, con las validaciones nativas correspondientes.

```html
<section id="contacto">
  <p class="etiqueta">Contacto</p>
  <h2>¿Listo para tener visibilidad total de tu energía?</h2>
  <p>Cuéntanos sobre tu instalación y te preparamos un diagnóstico inicial sin costo.</p>
  <form>
    <label for="nombre">Nombre</label>
    <input type="text" id="nombre" name="nombre" required>

    <label for="empresa">Empresa</label>
    <input type="text" id="empresa" name="empresa" required>

    <label for="correo">Correo electrónico</label>
    <input type="email" id="correo" name="correo" required>

    <label for="mensaje">Cuéntanos tu situación</label>
    <textarea id="mensaje" name="mensaje" rows="4" required></textarea>

    <button type="submit">Enviar mensaje</button>
  </form>
  <p><small>Respondemos en menos de 24 horas hábiles.</small></p>
</section>
```

### Paso 10 — Footer

El footer real tiene 3 columnas: descripción de la empresa, enlaces de "Producto" (los mismos del nav), y datos de contacto + aviso de privacidad.

```html
<footer>
  <div class="footer-col">
    <p class="logo">denki</p>
    <p>Medición energética inteligente para empresas. Dispositivos IoT, plataforma de monitoreo e instalación fotovoltaica.</p>
  </div>
  <div class="footer-col">
    <h4>Producto</h4>
    <a href="#soluciones">Soluciones</a>
    <a href="#como-funciona">Cómo funciona</a>
    <a href="#casos-de-uso">Casos de uso</a>
    <a href="#faq">FAQ</a>
  </div>
  <div class="footer-col">
    <h4>Contacto</h4>
    <a href="mailto:contacto@denkipower.com">contacto@denkipower.com</a>
    <a href="tel:+525500000000">+52 (55) 0000-0000</a>
  </div>
  <p class="copyright">&copy; 2026 Denki Power Systems. Todos los derechos reservados.</p>
</footer>
```
**CSS:** Flexbox con `justify-content: space-between` para las 3 columnas, colapsando a columna única en móvil — el mismo patrón responsivo usado en el header (Paso 1), reforzando que unas pocas técnicas de Flexbox/Grid bien entendidas resuelven la mayoría de los layouts de un sitio completo.

### Paso 11 — Responsividad general

Con todas las secciones construidas, revisa el sitio completo en un ancho de pantalla móvil (usando las herramientas de desarrollador del navegador, o reduciendo la ventana). Aplica media queries (sección 3.14) para: apilar el header en columna o convertirlo en un menú simplificado, hacer que todas las cuadrículas (`grid-tarjetas`, `pasos`, `grid-casos`) pasen a una sola columna, y reducir el tamaño de fuente del `<h1>` del hero para que no se vea desproporcionado en pantallas pequeñas.

---

### Ejercicio 1.1 — Estructura semántica básica
Crea la estructura semántica (sin contenido real, solo el esqueleto) de la futura landing page de Denki: header con logo y navegación, una sección hero, una sección de características, y footer.

**Respuesta:**
```html
<header>
  <img src="logo-denki.svg" alt="Logo Denki Power Systems">
  <nav>
    <a href="#caracteristicas">Características</a>
    <a href="#contacto">Contacto</a>
  </nav>
</header>

<main>
  <section id="hero">
    <h1>Monitoreo eléctrico en tiempo real</h1>
    <p>Denki te ayuda a detectar fallas antes de que ocurran.</p>
  </section>

  <section id="caracteristicas">
    <article>
      <h2>Alertas en tiempo real</h2>
    </article>
    <article>
      <h2>Historial de lecturas</h2>
    </article>
  </section>
</main>

<footer>
  <p>&copy; 2026 Denki Power Systems</p>
</footer>
```

### Ejercicio 1.2 — Formulario con validación nativa
Crea el formulario de "lista de espera" de la landing: nombre, correo y un select de "tipo de instalación" (industrial, residencial, comercial), con validaciones nativas.

**Respuesta:**
```html
<form>
  <label for="nombre">Nombre:</label>
  <input type="text" id="nombre" name="nombre" required minlength="2">

  <label for="correo">Correo:</label>
  <input type="email" id="correo" name="correo" required>

  <label for="tipo">Tipo de instalación:</label>
  <select id="tipo" name="tipo" required>
    <option value="">-- Selecciona --</option>
    <option value="industrial">Industrial</option>
    <option value="residencial">Residencial</option>
    <option value="comercial">Comercial</option>
  </select>

  <button type="submit">Unirme a la lista de espera</button>
</form>
```

### Ejercicio 1.3 — Box model y box-sizing
Dado el siguiente CSS, calcula el ancho visible total de la caja **antes** y **después** de agregar `box-sizing: border-box`:
```css
.caja { width: 300px; padding: 15px; border: 5px solid black; }
```

**Respuesta:** Sin `border-box`: 300 + (15×2) + (5×2) = **340px** de ancho visible total. Con `box-sizing: border-box`: el ancho visible total es exactamente **300px**, porque el padding y el border se restan internamente del contenido para que la caja completa respete el `width` declarado.

### Ejercicio 1.4 — Flexbox: barra de navegación
Crea, usando Flexbox, una barra de navegación con el logo a la izquierda y los enlaces distribuidos a la derecha con espacio uniforme entre ellos.

**Respuesta:**
```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
}
.navbar .enlaces {
  display: flex;
  gap: 24px;
}
```

### Ejercicio 1.5 — Grid responsivo de tarjetas
Crea una cuadrícula de tarjetas de "características" que muestre tantas columnas de mínimo 250px como quepan, sin usar ninguna media query.

**Respuesta:**
```css
.caracteristicas {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 24px;
}
```

### Ejercicio 1.6 — Especificidad
¿Qué color tendrá el texto del siguiente botón, y por qué?
```css
button { color: black; }
.btn-primario { color: white; }
#btn-enviar { color: red; }
```
```html
<button id="btn-enviar" class="btn-primario">Enviar</button>
```

**Respuesta:** **Rojo**, porque el selector por `id` (`#btn-enviar`) tiene mayor especificidad que el selector por clase (`.btn-primario`) y que el selector por etiqueta (`button`), independientemente del orden en que se escribieron las reglas.

