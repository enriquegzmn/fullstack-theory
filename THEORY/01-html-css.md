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

**Proyecto #1 — Landing Page Responsiva**: debe tener una sección "hero" amplia con título, subtítulo y botón de llamado a la acción, seguida de secciones de características, testimonios y formulario de contacto, todo perfectamente adaptado a móvil.

**Proyecto #2 — Portafolio Personal**: sitio de una sola página con secciones claras (sobre mí, habilidades, proyectos en tarjetas, contacto), diseño limpio y profesional, construido con Tailwind CSS.

(Ver las imágenes de referencia mostradas en la conversación para ejemplos visuales reales de landing pages y portafolios de desarrolladores.)

---

## Ejercicios del Bloque 01 (con respuesta)

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

