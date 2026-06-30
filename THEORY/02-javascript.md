# Teoría Detallada — Bloque 02: JavaScript (Semanas 3-4)

## 1. ¿Qué es JavaScript y cómo se ejecuta?

JavaScript es un lenguaje de **programación** (a diferencia de HTML/CSS, que son lenguajes de marcado y estilo). Permite definir lógica: tomar decisiones, repetir acciones, guardar y transformar datos, y reaccionar a las acciones del usuario.

```html
<script src="script.js" defer></script>
```
El atributo `defer` le dice al navegador: "descarga este script en paralelo mientras sigues leyendo el HTML, pero ejecútalo solo cuando el HTML esté completamente listo". Esto evita errores comunes de principiante donde el script intenta manipular un elemento que el navegador todavía no ha leído.

## 2. Variables: cajas que guardan información

```js
let edad = 25;        // puede reasignarse después
const PI = 3.1416;    // NO puede reasignarse (constante)
```

Piensa en una variable como una **caja con etiqueta**: `let edad = 25` crea una caja llamada "edad" y mete el valor 25 dentro. Más adelante puedes abrir esa caja y cambiar su contenido (`edad = 26`), pero solo si la declaraste con `let`. Si la declaraste con `const`, la caja queda sellada — no puedes volver a meter algo distinto dentro (aunque, si guarda un objeto o array, sí puedes modificar su contenido interno, solo no puedes reasignar la variable a otra cosa por completo).

**Regla práctica**: usa `const` por defecto siempre; cambia a `let` solo cuando sepas que necesitarás reasignar el valor más adelante (por ejemplo, un contador). Evita `var` (forma antigua con comportamiento confuso de scope).

### Scope (alcance) de las variables
El "scope" es la región del código donde una variable existe y puede usarse.

```js
let global = "puedo verme en todo el archivo";

function ejemplo() {
  let local = "solo existo dentro de esta función";
  console.log(global); // funciona, puede ver variables externas
  console.log(local);  // funciona
}

console.log(local); // ERROR: local no existe fuera de la función
```

`let` y `const` tienen **scope de bloque**: solo existen dentro de las llaves `{ }` donde fueron declaradas (un `if`, un `for`, una función).

## 3. Tipos de datos

```js
// Primitivos (valores simples, inmutables)
let texto = "Hola";             // string
let numero = 10;                  // number (no hay distinción entre enteros y decimales)
let activo = true;                 // boolean
let vacio = null;                   // ausencia intencional de valor
let sinDefinir;                      // undefined: variable declarada pero sin valor asignado

// De referencia (estructuras complejas)
let arreglo = [1, 2, 3];
let objeto = { nombre: "Kiki", edad: 30 };
```

`typeof variable` permite saber el tipo de dato en tiempo de ejecución: `typeof 10` devuelve `"number"`, `typeof "hola"` devuelve `"string"`.

**Diferencia clave entre primitivos y referencias**: cuando copias un primitivo, se copia el **valor**; cuando copias un objeto/array, se copia la **referencia** (la dirección en memoria), no el contenido:

```js
let a = 5;
let b = a;
b = 10;
console.log(a); // 5 (no se afectó)

let obj1 = { valor: 5 };
let obj2 = obj1;
obj2.valor = 10;
console.log(obj1.valor); // 10 (¡sí se afectó! obj1 y obj2 apuntan al mismo objeto)
```
Este comportamiento confunde mucho a principiantes y es una causa frecuente de bugs.

## 4. Operadores

```js
// Aritméticos
10 + 5;  10 - 5;  10 * 5;  10 / 5;  10 % 3; // % = módulo, el RESIDUO de una división (10 % 3 = 1)

// Comparación
5 === 5;   // igualdad ESTRICTA: compara valor Y tipo (recomendado siempre)
5 == "5";  // igualdad DÉBIL: convierte tipos antes de comparar (true, aunque uno sea número y otro string) — EVITAR
5 !== 4;   // distinto estricto
5 > 3; 5 < 3; 5 >= 5; 5 <= 4;

// Lógicos
true && false; // AND: true solo si AMBOS son true
true || false; // OR: true si AL MENOS UNO es true
!true;          // NOT: invierte el valor

// Asignación compuesta
let x = 10;
x += 5;  // equivale a x = x + 5
x -= 2;  // equivale a x = x - 2
x *= 2;  // equivale a x = x * 2
```

**Por qué usar siempre `===` y no `==`**: `==` hace conversión de tipo automática (coerción), lo que puede producir resultados sorprendentes: `0 == false` es `true`, `"" == false` es `true`, `null == undefined` es `true`. Estas conversiones implícitas son una fuente común de bugs difíciles de detectar, por eso la práctica profesional recomienda usar siempre `===`/`!==`.

## 5. Estructuras condicionales

```js
let edad = 20;

if (edad >= 18) {
  console.log("Es mayor de edad");
} else if (edad >= 13) {
  console.log("Es adolescente");
} else {
  console.log("Es menor de edad");
}
```
El programa evalúa las condiciones **en orden**, de arriba hacia abajo, y ejecuta el primer bloque cuya condición sea `true`, ignorando el resto.

```js
// Operador ternario: forma corta de un if/else que devuelve un valor
let mensaje = edad >= 18 ? "Adulto" : "Menor";
```
Estructura: `condición ? valorSiVerdadero : valorSiFalso`. Útil cuando la decisión es simple y se necesita asignar directamente un valor.

```js
switch (edad) {
  case 18:
    console.log("Recién cumplió la mayoría");
    break; // IMPORTANTE: sin break, el código sigue ejecutando los siguientes case (esto se llama "fall-through")
  case 21:
    console.log("Otra edad específica");
    break;
  default:
    console.log("Cualquier otra edad");
}
```

## 6. Bucles (loops)

```js
// for: cuando sabes exactamente cuántas veces repetir
for (let i = 0; i < 5; i++) {
  console.log(i); // imprime 0, 1, 2, 3, 4
}
```
Anatomía del `for`: `(inicialización; condición; incremento)`. La inicialización se ejecuta una vez al inicio; antes de cada vuelta se evalúa la condición (si es `false`, el bucle termina); después de cada vuelta se ejecuta el incremento.

```js
// while: mientras se cumpla una condición (no se sabe de antemano cuántas veces)
let contador = 0;
while (contador < 5) {
  console.log(contador);
  contador++; // IMPORTANTE: si olvidas esto, el bucle nunca termina (bucle infinito)
}
```

```js
// for...of: recorrer los VALORES de un array directamente
for (const item of [10, 20, 30]) {
  console.log(item);
}

// for...in: recorrer las CLAVES (keys) de un objeto
const persona = { nombre: "Kiki", edad: 30 };
for (const clave in persona) {
  console.log(clave, persona[clave]);
}
```

## 7. Funciones: bloques de código reutilizables

```js
// Declaración tradicional (function declaration)
function sumar(a, b) {
  return a + b;
}

// Expresión de función (function expression)
const sumar2 = function (a, b) {
  return a + b;
};

// Función flecha (arrow function) — sintaxis moderna y muy usada
const sumar3 = (a, b) => a + b; // si el cuerpo es una sola línea de retorno, se puede omitir { return }

// Con valores por defecto en los parámetros
function saludar(nombre = "invitado") {
  return `Hola, ${nombre}`;
}
saludar();         // "Hola, invitado"
saludar("Kiki");    // "Hola, Kiki"
```

**`return` es crítico**: una función sin `return` explícito devuelve `undefined`. El `return` también **detiene la ejecución** de la función inmediatamente, por lo que cualquier código después de un `return` dentro del mismo bloque nunca se ejecuta.

### Closures (concepto introductorio)
Un closure ocurre cuando una función "recuerda" las variables del entorno donde fue creada, incluso después de que ese entorno ya terminó de ejecutarse:

```js
function crearContador() {
  let contador = 0;
  return function () {
    contador++;
    return contador;
  };
}

const contar = crearContador();
console.log(contar()); // 1
console.log(contar()); // 2
console.log(contar()); // 3
```
Cada vez que se llama a `contar()`, "recuerda" el valor de `contador` de la llamada anterior, porque la función interna mantiene acceso a la variable de su función contenedora. Este patrón se usa, entre otras cosas, para crear variables "privadas" en JavaScript.

## 8. Arrays y sus métodos más importantes

```js
const numeros = [1, 2, 3, 4, 5];

numeros.push(6);     // agrega 6 al final, MODIFICA el array original
numeros.pop();         // quita y devuelve el último elemento
numeros.unshift(0);     // agrega al inicio
numeros.shift();          // quita el primero
numeros.length;             // cantidad de elementos
numeros[0];                  // acceso por índice (empieza en 0)
```

**Los tres métodos más importantes en entrevistas y en proyectos reales**:

```js
// map: TRANSFORMA cada elemento y devuelve un NUEVO array de la misma longitud
const dobles = numeros.map(n => n * 2); // [2,4,6,8,10]

// filter: FILTRA elementos según una condición, devuelve un NUEVO array (puede ser más corto)
const pares = numeros.filter(n => n % 2 === 0); // [2,4]

// reduce: ACUMULA todos los elementos en UN SOLO valor (suma, producto, objeto, etc.)
const suma = numeros.reduce((acumulador, actual) => acumulador + actual, 0);
// 0 es el valor inicial del acumulador; en cada vuelta, acumulador + actual se convierte en el nuevo acumulador
```

Estos tres métodos **no modifican el array original** (a diferencia de `push`/`pop`/`splice`), siguen el principio de **inmutabilidad**, muy valorado en código moderno porque hace el comportamiento más predecible.

Otros métodos útiles:
```js
numeros.find(n => n > 3);        // devuelve el PRIMER elemento que cumple la condición (o undefined)
numeros.findIndex(n => n > 3);    // devuelve el ÍNDICE del primer elemento que cumple
numeros.some(n => n > 3);          // true si AL MENOS UNO cumple la condición
numeros.every(n => n > 0);          // true si TODOS cumplen la condición
numeros.includes(3);                 // true si el valor existe en el array
numeros.sort((a, b) => a - b);        // ordena de menor a mayor (sin la función de comparación, ordena como texto, lo cual da resultados incorrectos con números)
numeros.slice(1, 3);                   // extrae una porción SIN modificar el original
numeros.splice(1, 2);                   // elimina/inserta elementos, SÍ modifica el original
```

## 9. Objetos

```js
const producto = {
  nombre: "Sensor BMP280",
  precio: 120,
  enStock: true,
  mostrarInfo() {
    return `${this.nombre} cuesta $${this.precio}`;
  }
};

producto.nombre;        // acceso con punto (notación más común)
producto["precio"];      // acceso con corchetes (necesario si la clave tiene espacios o es dinámica)
producto.precio = 100;     // modificar una propiedad existente
producto.descuento = 10;     // agregar una propiedad nueva
delete producto.enStock;       // eliminar una propiedad
```

`this` dentro de un método de objeto se refiere **al objeto que llamó al método** — en este caso, `this.nombre` dentro de `mostrarInfo()` es lo mismo que `producto.nombre`.

### Destructuring (extracción rápida de propiedades)
```js
const { nombre, precio } = producto;
console.log(nombre); // "Sensor BMP280", sin necesidad de escribir producto.nombre
```

### Spread operator (expandir)
```js
const productoConDescuento = { ...producto, precio: 100 }; // copia todas las propiedades de producto, y sobrescribe precio
const copiaArray = [...numeros]; // crea una copia nueva del array (no la misma referencia)
```

## 10. Template literals

```js
const nombre = "Kiki";
const edad = 30;
console.log(`Hola, soy ${nombre} y tengo ${edad} años.`); // usa comillas invertidas (backticks) y ${}
```
Permite insertar variables y expresiones directamente dentro de un string, y también permite strings multilínea sin necesidad de concatenación.

---

## 11. El DOM (Document Object Model)

El DOM es la representación en memoria de la página HTML como un **árbol de objetos** que JavaScript puede leer y modificar. Cuando el navegador carga el HTML, construye este árbol; cada etiqueta se convierte en un "nodo" del árbol con el que se puede interactuar.

### Seleccionar elementos
```js
document.getElementById("titulo");          // por id, devuelve UN elemento
document.querySelector(".clase");            // el PRIMER elemento que coincide con el selector CSS
document.querySelectorAll("li");             // TODOS los elementos que coinciden (devuelve una NodeList, similar a un array)
```
`querySelector`/`querySelectorAll` aceptan **cualquier selector CSS válido** (`.clase`, `#id`, `div > p`, `[data-categoria="sensores"]`), lo que los hace mucho más flexibles que `getElementById`.

### Modificar contenido
```js
const titulo = document.querySelector("h1");

titulo.textContent = "Nuevo texto";   // cambia solo el TEXTO, de forma segura
titulo.innerHTML = "<em>Texto</em>";   // permite insertar HTML; usar con cuidado (riesgo de seguridad si el contenido viene de un usuario externo, conocido como XSS)
```

### Modificar estilos y clases
```js
titulo.style.color = "red";              // estilo en línea directo (poco recomendado para cambios complejos)
titulo.classList.add("activo");           // agrega una clase (mejor práctica: manipular clases, no estilos directos)
titulo.classList.remove("oculto");
titulo.classList.toggle("destacado");      // agrega si no está, quita si ya está presente
titulo.classList.contains("activo");        // true/false si tiene esa clase
```
**Mejor práctica**: definir los estilos en CSS usando clases, y desde JavaScript solo agregar/quitar esas clases (`classList`), en vez de escribir estilos directamente desde JS. Esto mantiene la separación entre estructura/lógica (HTML/JS) y presentación (CSS).

### Eventos

```js
const boton = document.querySelector("#miBoton");

boton.addEventListener("click", function (evento) {
  console.log("Clic detectado");
  console.log(evento.target); // el elemento exacto que disparó el evento
});
```
`addEventListener` "escucha" una acción del usuario (`click`, `submit`, `input`, `change`, `keydown`, `mouseover`) y ejecuta una función cuando ocurre. Se pueden agregar **múltiples** listeners al mismo elemento sin que se sobrescriban entre sí (a diferencia de asignar `onclick = ...` directamente).

**Bubbling (burbujeo) de eventos**: cuando ocurre un evento en un elemento, también se dispara en todos sus elementos "padre" en el árbol DOM, de adentro hacia afuera, como burbujas subiendo. Esto permite una técnica llamada "delegación de eventos": en vez de poner un listener en cada uno de 100 botones, se pone un solo listener en su contenedor padre y se revisa `evento.target` para saber cuál botón específico se presionó.

### Crear y eliminar elementos dinámicamente
```js
const lista = document.querySelector("#lista");

const nuevoItem = document.createElement("li");
nuevoItem.textContent = "Nueva tarea";
lista.appendChild(nuevoItem); // lo agrega al final de la lista

nuevoItem.remove(); // lo elimina del DOM
```

### Formularios y `preventDefault`
```js
const formulario = document.querySelector("form");

formulario.addEventListener("submit", (evento) => {
  evento.preventDefault(); // EVITA que la página se recargue (comportamiento por defecto de los formularios HTML)
  const valor = document.querySelector("#tarea").value;
  console.log("Valor enviado:", valor);
});
```

### localStorage: persistencia de datos en el navegador
```js
localStorage.setItem("usuario", JSON.stringify({ nombre: "Kiki" })); // guardar (solo acepta strings, por eso se usa JSON.stringify)
const datos = JSON.parse(localStorage.getItem("usuario"));            // leer y convertir de vuelta a objeto
localStorage.removeItem("usuario");                                    // eliminar
localStorage.clear();                                                    // eliminar TODO
```
`localStorage` persiste incluso si el usuario cierra el navegador y vuelve después; es distinto de `sessionStorage`, que se borra al cerrar la pestaña.

---

## 12. Asincronía en JavaScript

### El problema: operaciones que tardan tiempo
JavaScript es de un solo hilo (single-threaded): ejecuta una instrucción a la vez. Pero hay operaciones que tardan (pedir datos a un servidor, leer un archivo) y no queremos que la página se "congele" mientras esperan. Para esto existe la asincronía.

### Callbacks (forma antigua)
```js
function obtenerDatos(callback) {
  setTimeout(() => {
    callback("Datos recibidos");
  }, 1000);
}

obtenerDatos((resultado) => {
  console.log(resultado);
});
```
Cuando se anidan muchos callbacks dentro de otros, se genera el llamado "callback hell" (infierno de callbacks): código difícil de leer en forma de pirámide. Esto llevó a la creación de las Promesas.

### Promesas
```js
function obtenerDatos() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const exito = true;
      if (exito) {
        resolve("Datos recibidos");
      } else {
        reject("Error al obtener datos");
      }
    }, 1000);
  });
}

obtenerDatos()
  .then(resultado => console.log(resultado))
  .catch(error => console.error(error))
  .finally(() => console.log("Operación terminada"));
```
Una promesa representa un valor que **estará disponible en el futuro**. Tiene 3 estados: `pending` (pendiente), `fulfilled` (resuelta con éxito, dispara `.then()`), `rejected` (falló, dispara `.catch()`). `.finally()` se ejecuta siempre, haya éxito o error.

### async/await (forma moderna, recomendada)
```js
async function cargarDatos() {
  try {
    const resultado = await obtenerDatos();
    console.log(resultado);
  } catch (error) {
    console.error("Hubo un error:", error);
  }
}
```
`async` antes de una función indica que esa función devolverá una promesa automáticamente. `await` "pausa" la ejecución de esa función (sin bloquear el resto de la página) hasta que la promesa se resuelva, permitiendo escribir código asíncrono **como si fuera síncrono**, mucho más legible que encadenar `.then()`. El manejo de errores se hace con `try/catch`, igual que en código síncrono normal.

### fetch(): consumir APIs reales
```js
async function obtenerProductos() {
  try {
    const respuesta = await fetch("https://api.ejemplo.com/productos");
    if (!respuesta.ok) {
      throw new Error(`Error HTTP: ${respuesta.status}`);
    }
    const datos = await respuesta.json(); // convierte la respuesta a un objeto/array JS
    return datos;
  } catch (error) {
    console.error("No se pudieron cargar los productos:", error);
    return [];
  }
}
```

`fetch()` por defecto hace una petición `GET`. Para enviar datos (`POST`):
```js
async function crearProducto(producto) {
  const respuesta = await fetch("https://api.ejemplo.com/productos", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(producto)
  });
  return await respuesta.json();
}
```

**Manejo de estados de UI**, patrón fundamental en cualquier app real:
```js
let cargando = true;
let error = null;
let datos = [];

async function cargar() {
  cargando = true;
  error = null;
  try {
    datos = await obtenerProductos();
  } catch (e) {
    error = "No se pudieron cargar los datos";
  } finally {
    cargando = false;
  }
  actualizarInterfaz(); // función que muestra/oculta el spinner, el mensaje de error, o los datos según corresponda
}
```
Toda interfaz que consume datos externos debe contemplar **3 estados posibles**: cargando, error, y éxito (con datos) — además del caso "éxito pero sin resultados" (lista vacía).

---

## Imágenes de referencia para los proyectos de este bloque

**Proyecto #3 — App de Productividad (To-Do List)**: lista de tareas con checkbox para completar, filtros (todas/pendientes/completadas), categorías con colores y contador de pendientes — interfaz limpia tipo tarjeta.

**Proyecto #4 — Dashboard de API real**: vista con buscador en la parte superior, resultados en tarjetas o lista, e indicadores visuales claros para los estados de carga y error.

(Ver las imágenes de referencia de "to-do list app UI" mostradas en la conversación.)

---

## Ejercicios del Bloque 02 (con respuesta)

### Ejercicio 2.1 — Closures y scope
¿Qué imprime el siguiente código y por qué?
```js
function crear() {
  let valor = 0;
  return () => {
    valor++;
    return valor;
  };
}
const f1 = crear();
const f2 = crear();
console.log(f1(), f1(), f2());
```

**Respuesta:** `1 2 1`. `f1` y `f2` son closures **independientes**, cada una "recuerda" su propia variable `valor` porque cada llamada a `crear()` genera un nuevo entorno. `f1()` se llama dos veces seguidas (1, luego 2), y `f2()` es la primera llamada de su propio closure (1).

### Ejercicio 2.2 — map, filter y reduce combinados (dominio Denki)
Dado un array de lecturas de sensores, obtén el promedio de temperatura **solo** de los sensores del tipo `"BMP280"`.
```js
const lecturas = [
  { sensor: "BMP280", temperatura: 24 },
  { sensor: "DHT22", temperatura: 30 },
  { sensor: "BMP280", temperatura: 26 }
];
```

**Respuesta:**
```js
const bmp280 = lecturas.filter(l => l.sensor === "BMP280");
const promedio = bmp280.reduce((acc, l) => acc + l.temperatura, 0) / bmp280.length;
console.log(promedio); // 25
```

### Ejercicio 2.3 — Manipulación del DOM con delegación de eventos
Tienes una lista `<ul id="sensores">` con varios `<li>` generados dinámicamente, cada uno con un botón "Eliminar". En vez de poner un listener en cada botón, usa delegación de eventos con un solo listener en el `<ul>`.

**Respuesta:**
```js
document.querySelector("#sensores").addEventListener("click", (evento) => {
  if (evento.target.matches("button.eliminar")) {
    evento.target.closest("li").remove();
  }
});
```
`evento.target` identifica el elemento exacto donde ocurrió el clic (gracias al bubbling), y `closest("li")` encuentra el `<li>` contenedor más cercano para eliminarlo, sin importar cuántos botones existan en la lista.

### Ejercicio 2.4 — Promesas y async/await
Reescribe el siguiente código basado en `.then()` usando `async/await` con manejo de errores:
```js
function obtenerLecturas() {
  return fetch("/api/lecturas").then(r => r.json());
}
obtenerLecturas().then(datos => console.log(datos)).catch(e => console.error(e));
```

**Respuesta:**
```js
async function obtenerLecturas() {
  try {
    const respuesta = await fetch("/api/lecturas");
    const datos = await respuesta.json();
    console.log(datos);
  } catch (e) {
    console.error(e);
  }
}
obtenerLecturas();
```

### Ejercicio 2.5 — localStorage con objetos
Guarda en `localStorage` un array de "dispositivos favoritos" (ids), y crea una función que agregue un nuevo id sin duplicarlo.

**Respuesta:**
```js
function agregarFavorito(id) {
  const favoritos = JSON.parse(localStorage.getItem("favoritos")) || [];
  if (!favoritos.includes(id)) {
    favoritos.push(id);
    localStorage.setItem("favoritos", JSON.stringify(favoritos));
  }
}
```

### Ejercicio 2.6 — Manejo de los 3 estados de UI
Escribe la lógica (sin librerías, JS puro) que controle los estados de carga, error y éxito al pedir lecturas de sensores a una API, mostrando/ocultando elementos del DOM según corresponda.

**Respuesta:**
```js
async function cargarLecturas() {
  const spinner = document.querySelector("#cargando");
  const errorEl = document.querySelector("#error");
  const lista = document.querySelector("#lista-lecturas");

  spinner.classList.remove("oculto");
  errorEl.classList.add("oculto");

  try {
    const respuesta = await fetch("/api/lecturas");
    if (!respuesta.ok) throw new Error("Error al cargar lecturas");
    const datos = await respuesta.json();
    lista.innerHTML = datos.map(d => `<li>${d.sensor}: ${d.valor}</li>`).join("");
  } catch (e) {
    errorEl.textContent = e.message;
    errorEl.classList.remove("oculto");
  } finally {
    spinner.classList.add("oculto");
  }
}
```

