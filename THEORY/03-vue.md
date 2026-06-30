# Teoría Detallada — Bloque 03: Vue.js (Semanas 5-6, versión extendida)

Este bloque se extendió de 1 a 2 semanas completas. La razón: una sola semana resultaba insuficiente para que alguien sin experiencia previa en frameworks pasara de "entender la teoría" a "construir con fluidez". La división es la siguiente:

- **Semana 5 — Fundamentos**: reactividad, directivas, `computed`/`methods`/`watch`, ciclo de vida, componentes y comunicación (secciones 1 a 12 de este documento).
- **Semana 6 — Nivel de producción**: migración a Vite, Vue Router, Pinia, manejo de errores y construcción completa del proyecto insignia (secciones 13 a 17, nuevas en esta versión).

Cada sección está pensada para practicarse durante 1-2 días completos, no para leerse de un solo golpe.

## 1. ¿Qué problema resuelve Vue.js?

En el Bloque 02 viste cómo manipular el DOM manualmente: seleccionar un elemento, escuchar un evento, y actualizar el texto/clases a mano. En aplicaciones pequeñas esto funciona, pero en aplicaciones con muchos datos cambiantes (un carrito de compras, un dashboard), mantener sincronizado "a mano" el DOM con los datos se vuelve muy difícil y propenso a errores: olvidar actualizar un elemento, actualizar el orden incorrecto, etc.

Vue.js resuelve esto con **reactividad**: declaras tus datos, declaras cómo se ven en HTML (el "template"), y Vue se encarga automáticamente de mantener la interfaz sincronizada con los datos. Cuando un dato cambia, Vue actualiza **solo las partes del DOM que dependen de ese dato**, de forma eficiente, sin que tengas que escribir ese código de sincronización manualmente.

## 2. Instalación y primera app

Para aprender los fundamentos, se usa Vue 3 vía CDN, sin necesidad de instalar nada:

```html
<div id="app">
  {{ mensaje }}
</div>

<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
<script>
  const { createApp } = Vue;

  createApp({
    data() {
      return {
        mensaje: "Hola desde Vue"
      };
    }
  }).mount("#app");
</script>
```

- `createApp({...})`: crea una **instancia de aplicación**. El objeto que recibe es la "configuración" de la app: qué datos tiene, qué métodos, etc.
- `data()`: una función que **devuelve un objeto** con las propiedades reactivas de la app. Debe ser una función (no un objeto directo) para que cada instancia tenga sus propios datos independientes.
- `.mount("#app")`: conecta la instancia de Vue con el elemento HTML que tiene `id="app"`. Todo lo que esté dentro de ese `<div>` pasa a ser controlado por Vue.

**¿Qué significa "reactivo"?** Cuando Vue procesa el objeto que devuelve `data()`, internamente lo convierte para que cualquier cambio a esas propiedades dispare automáticamente una actualización de la interfaz. Esto se logra (en Vue 3) usando `Proxy` de JavaScript moderno, que permite "interceptar" cuándo se lee o escribe una propiedad.

## 3. Interpolación y enlace de atributos

```html
<div id="app">
  <p>{{ titulo }}</p>
  <img :src="imagenUrl" :alt="titulo">
  <a :href="enlace">Ir al sitio</a>
</div>
```
```js
createApp({
  data() {
    return { titulo: "Producto destacado", imagenUrl: "producto.jpg", enlace: "https://ejemplo.com" };
  }
}).mount("#app");
```

`{{ }}` (interpolación de texto) inserta el valor de una variable o expresión directamente dentro del HTML, y se actualiza automáticamente si el valor cambia.

`:atributo` es la forma corta de `v-bind:atributo`, y enlaza un atributo HTML a un valor dinámico de JavaScript. Sin los dos puntos (`src="imagenUrl"`), Vue interpretaría `imagenUrl` como un texto literal, no como el nombre de una variable.

## 4. Directivas condicionales

```html
<p v-if="enStock">Disponible</p>
<p v-else-if="enStock === false">Agotado</p>
<p v-else>Sin información</p>

<p v-show="mostrarAviso">Este aviso se oculta con CSS, no se elimina del DOM</p>
```

**Diferencia fundamental entre `v-if` y `v-show`**:
- `v-if` **agrega o elimina por completo** el elemento del DOM según la condición. Tiene un costo mayor cada vez que cambia (porque crea/destruye el elemento), pero si la condición es `false`, el elemento ni siquiera existe en el HTML.
- `v-show` **siempre mantiene el elemento en el DOM**, y solo alterna su CSS `display: none`. Es más eficiente cuando el elemento cambia de visibilidad muy frecuentemente, porque no hay que recrearlo cada vez.

Regla práctica: usa `v-show` para alternar visibilidad frecuente (como un menú desplegable que se abre/cierra muchas veces); usa `v-if` cuando la condición rara vez cambia o cuando el contenido es costoso de renderizar.

## 5. Renderizar listas con v-for

```html
<ul>
  <li v-for="producto in productos" :key="producto.id">
    {{ producto.nombre }} - ${{ producto.precio }}
  </li>
</ul>
```
```js
data() {
  return {
    productos: [
      { id: 1, nombre: "Sensor BMP280", precio: 120 },
      { id: 2, nombre: "Raspberry Pi", precio: 850 }
    ]
  };
}
```

`v-for="producto in productos"` recorre el array `productos` y crea una copia del elemento HTML por cada uno, con `producto` representando el elemento actual de la iteración (similar a un `for...of` de JavaScript, pero declarativo en el HTML).

**`:key` es obligatorio y crítico**: Vue necesita una forma de identificar de manera única cada elemento de la lista para saber, cuando la lista cambia (se agrega, elimina o reordena un elemento), exactamente cuál elemento del DOM debe actualizar, mover o eliminar — en vez de tener que recrear toda la lista desde cero. Usar el índice del array como `key` (`:key="index"`) funciona pero **no es recomendado** si la lista puede reordenarse o eliminar elementos del medio, porque los índices cambian y Vue puede confundir qué elemento es cuál. Lo ideal es usar un identificador único y estable, como un `id`.

## 6. Eventos con v-on

```html
<button @click="incrementar">Sumar</button>
<input @input="actualizarTexto" :value="texto">
<form @submit.prevent="enviarFormulario">...</form>
```
```js
methods: {
  incrementar() {
    this.contador++;
  },
  actualizarTexto(evento) {
    this.texto = evento.target.value;
  },
  enviarFormulario() {
    console.log("Formulario enviado");
  }
}
```

`@evento` es la forma corta de `v-on:evento`. Dentro de `methods`, `this` se refiere a la instancia de la app, dando acceso tanto a los datos (`this.contador`) como a otros métodos.

**Modificadores de eventos**, muy usados para simplificar código:
- `.prevent`: equivale a llamar `evento.preventDefault()` automáticamente (muy usado en formularios, para evitar la recarga de página).
- `.stop`: equivale a `evento.stopPropagation()`, detiene el bubbling del evento.
- `.once`: el listener se ejecuta solo una vez.

## 7. v-model: enlace bidireccional

```html
<input v-model="nombre" placeholder="Escribe tu nombre">
<p>Hola, {{ nombre }}</p>
```

`v-model` resume en una sola directiva el patrón "leer el valor actual del input + escuchar el evento de cambio + actualizar la variable", manteniendo sincronizados el campo del formulario y el dato de JavaScript **en ambas direcciones**: si el usuario escribe, la variable cambia; si la variable cambia desde código, el input se actualiza también.

Modificadores útiles de `v-model`:
```html
<input v-model.number="precio">  <!-- convierte automáticamente el valor a número, en vez de string -->
<input v-model.trim="nombre">     <!-- elimina espacios en blanco al inicio/final automáticamente -->
<input v-model.lazy="busqueda">    <!-- actualiza la variable solo al perder el foco (evento change), no en cada tecla (evento input) -->
```

## 8. Computed properties vs methods vs watch

Estos tres conceptos suelen confundirse al inicio; es importante entender la diferencia:

```js
data() {
  return { precio: 100, cantidad: 3, carrito: [] };
},
computed: {
  // Se RECALCULA automáticamente solo cuando sus dependencias cambian, y se CACHEA (guarda el resultado)
  total() {
    return this.precio * this.cantidad;
  }
},
methods: {
  // Se ejecuta SOLO cuando se llama explícitamente, NO se cachea, puede recibir parámetros
  calcularDescuento(porcentaje) {
    return this.total * (porcentaje / 100);
  }
},
watch: {
  // Se ejecuta como un EFECTO SECUNDARIO cuando una propiedad específica cambia
  carrito(nuevoValor, valorAnterior) {
    console.log("El carrito cambió de", valorAnterior, "a", nuevoValor);
    localStorage.setItem("carrito", JSON.stringify(nuevoValor));
  }
}
```

**Cuándo usar cada uno:**
- **`computed`**: cuando necesitas un valor **derivado** de otros datos para mostrarlo en el template (un total, una lista filtrada, un texto formateado). Se recalcula automáticamente y de forma eficiente (solo si cambian sus dependencias).
- **`methods`**: cuando necesitas ejecutar una acción en respuesta a un evento (un clic), o cuando el cálculo necesita parámetros variables que no se pueden expresar como una simple "dependencia".
- **`watch`**: cuando necesitas reaccionar a un cambio de dato para hacer algo que **no es** actualizar el template — como guardar en `localStorage`, hacer una petición a una API, o mostrar una notificación.

```js
watch: {
  carrito: {
    handler(nuevoValor) {
      this.guardarCarrito(nuevoValor);
    },
    deep: true // necesario cuando el cambio ocurre DENTRO de un objeto/array (ej: cambiar la cantidad de un item existente), no solo cuando se reemplaza el array completo
  }
}
```

## 9. Ciclo de vida de un componente

Cada componente de Vue pasa por una serie de etapas (el "ciclo de vida"), y Vue permite ejecutar código en momentos específicos mediante "hooks" (ganchos):

```js
export default {
  created() {
    // el componente ya tiene acceso a sus datos reactivos, pero AÚN NO está en el DOM
  },
  mounted() {
    // el componente YA está insertado en el DOM real, ideal para cargar datos iniciales (localStorage, fetch a una API)
    const guardado = localStorage.getItem("carrito");
    if (guardado) this.carrito = JSON.parse(guardado);
  },
  updated() {
    // se ejecuta cada vez que el DOM se actualiza por un cambio reactivo
  },
  unmounted() {
    // el componente fue eliminado del DOM, ideal para limpiar listeners, temporizadores, etc.
  }
}
```
`mounted()` es, de lejos, el hook más usado por principiantes: es el lugar correcto para "arrancar" la aplicación con datos (recuperar de `localStorage`, hacer la primera petición `fetch`).

## 10. Componentes: dividir la interfaz en piezas reutilizables

A medida que una aplicación crece, conviene dividirla en componentes independientes, cada uno con su propio `data`, `methods` y `template`.

```js
const app = Vue.createApp({
  data() {
    return { productos: [{ id: 1, nombre: "Sensor", precio: 80 }] };
  }
});

app.component("producto-card", {
  props: ["nombre", "precio"], // datos que el componente RECIBE desde su padre
  template: `
    <div class="card">
      <h3>{{ nombre }}</h3>
      <p>${{ precio }}</p>
    </div>
  `
});

app.mount("#app");
```
```html
<div id="app">
  <producto-card
    v-for="p in productos"
    :key="p.id"
    :nombre="p.nombre"
    :precio="p.precio">
  </producto-card>
</div>
```

**`props` son de solo lectura**: el componente hijo NUNCA debe modificar directamente un prop recibido (`this.precio = 100` dentro del hijo generaría una advertencia y rompería el flujo de datos). Si el componente necesita una versión modificable, debe copiar el valor a su propio `data`.

Se puede (y suele ser más limpio) pasar un objeto completo en vez de propiedades sueltas:
```js
app.component("producto-card", {
  props: ["producto"],
  template: `<div class="card"><h3>{{ producto.nombre }}</h3></div>`
});
```
```html
<producto-card :producto="p"></producto-card>
```

## 11. Comunicación de hijo a padre con $emit

Los datos fluyen de padre a hijo mediante `props`. Para que un hijo le "avise" algo al padre (por ejemplo, "el usuario quiere agregar este producto al carrito"), se usan **eventos personalizados**:

```js
app.component("producto-card", {
  props: ["producto"],
  emits: ["agregar"], // buena práctica: declarar explícitamente qué eventos puede emitir el componente
  template: `
    <div class="card">
      <h3>{{ producto.nombre }}</h3>
      <button @click="$emit('agregar', producto)">Agregar al carrito</button>
    </div>
  `
});
```
```html
<producto-card :producto="p" @agregar="agregarAlCarrito"></producto-card>
```
```js
methods: {
  agregarAlCarrito(producto) {
    this.carrito.push(producto);
  }
}
```

Este patrón se conoce como **"props hacia abajo, eventos hacia arriba"** (props down, events up), y es el principio fundamental de comunicación entre componentes en Vue: los datos siempre fluyen de padre a hijo de forma explícita y predecible (vía props), y los hijos nunca modifican directamente el estado del padre, sino que le piden que lo haga emitiendo un evento.

## 12. Slots: contenido personalizable dentro de un componente

```js
app.component("tarjeta", {
  template: `<div class="card"><slot></slot></div>`
});
```
```html
<tarjeta>
  <h3>Contenido personalizado dentro de la tarjeta</h3>
</tarjeta>
```
Un `slot` es un "hueco" dentro del template del componente donde se inserta el contenido HTML que el padre decida, haciendo el componente mucho más flexible y reutilizable que si tuviera el contenido fijo.

## 13. Vite: el entorno de desarrollo profesional para Vue

(Las siguientes secciones, 13 a 17, corresponden a la Semana 6 — nivel producción. Antes de continuar, completa los ejercicios de la Semana 5 a continuación.)

---

## Ejercicios de la Semana 5 (fundamentos, con respuesta)

### Ejercicio 5.1 — v-if vs v-show
Para un panel de Denki, hay un mensaje de "alerta crítica" que se muestra/oculta muy frecuentemente según las lecturas entrantes. ¿Usarías `v-if` o `v-show`? Justifica e impleméntalo.

**Respuesta:** `v-show`, porque el elemento cambia de visibilidad con mucha frecuencia; recrear y destruir el elemento del DOM en cada lectura (como haría `v-if`) sería innecesariamente costoso.
```html
<div v-show="hayAlertaCritica" class="alerta">⚠️ Lectura fuera de rango</div>
```

### Ejercicio 5.2 — v-for con :key correcto
Dada una lista de sensores con `id` único, renderiza una lista usando `v-for`, usando la clave correcta (no el índice).

**Respuesta:**
```html
<li v-for="sensor in sensores" :key="sensor.id">{{ sensor.nombre }}: {{ sensor.valor }}</li>
```
Se usa `sensor.id` como `:key` en vez del índice del array, porque si la lista se reordena o se elimina un sensor del medio, los índices cambiarían y Vue podría confundir qué elemento del DOM corresponde a cuál dato.

### Ejercicio 5.3 — computed encadenada
Crea una `computed` `sensoresEnAlerta` que filtre los sensores cuyo valor supere un umbral, y otra `computed` `cantidadAlertas` que cuente cuántos hay, basada en la primera.

**Respuesta:**
```js
computed: {
  sensoresEnAlerta() {
    return this.sensores.filter(s => s.valor > this.umbral);
  },
  cantidadAlertas() {
    return this.sensoresEnAlerta.length;
  }
}
```
`cantidadAlertas` depende de `sensoresEnAlerta`, que a su vez depende de `sensores` y `umbral`: si cualquiera de esos cambia, ambas `computed` se recalculan automáticamente en cascada.

### Ejercicio 5.4 — Componente con props y $emit
Crea un componente `sensor-card` que reciba un sensor como prop y emita un evento `verDetalle` al hacer clic, que el padre escuche para mostrar más información.

**Respuesta:**
```js
app.component("sensor-card", {
  props: ["sensor"],
  emits: ["verDetalle"],
  template: `
    <div class="card" @click="$emit('verDetalle', sensor)">
      <h3>{{ sensor.nombre }}</h3>
      <p>{{ sensor.valor }}</p>
    </div>
  `
});
```
```html
<sensor-card v-for="s in sensores" :key="s.id" :sensor="s" @verDetalle="mostrarDetalle"></sensor-card>
```

---



Hasta ahora hemos usado Vue cargado desde un CDN, con todo en un solo archivo HTML — útil para aprender, pero no es como se construyen proyectos reales. **Vite** es una herramienta de build moderna que permite organizar un proyecto Vue en múltiples archivos `.vue` (Single File Components), con recarga instantánea durante el desarrollo y un proceso de `build` optimizado para producción (visto en detalle en el Bloque 07 de Despliegue).

```bash
npm create vite@latest mi-tienda -- --template vue
cd mi-tienda
npm install
npm run dev
```

Esto genera una estructura de carpetas como:
```
mi-tienda/
  src/
    components/
      ProductoCard.vue
    App.vue
    main.js
  index.html
  package.json
```

### Anatomía de un Single File Component (`.vue`)

```vue
<template>
  <div class="card">
    <h3>{{ producto.nombre }}</h3>
    <button @click="$emit('agregar', producto)">Agregar</button>
  </div>
</template>

<script>
export default {
  name: "ProductoCard",
  props: ["producto"],
  emits: ["agregar"]
};
</script>

<style scoped>
.card {
  border: 1px solid #ddd;
  padding: 16px;
}
</style>
```

Cada archivo `.vue` agrupa, para un mismo componente, su **estructura** (`<template>`), su **lógica** (`<script>`) y sus **estilos** (`<style>`) — a diferencia del enfoque con CDN, donde todo vivía mezclado en un solo archivo HTML gigante. El atributo `scoped` en `<style>` es importante: hace que esos estilos **solo afecten a este componente**, evitando que una clase como `.card` choque accidentalmente con otra `.card` de un componente distinto en el mismo proyecto.

### Importar y registrar componentes

```js
// App.vue
<script>
import ProductoCard from './components/ProductoCard.vue';

export default {
  components: { ProductoCard },
  data() {
    return { productos: [...] };
  }
};
</script>
```

A diferencia del registro global que usábamos con `app.component(...)` en el enfoque CDN, aquí cada componente se **importa explícitamente** donde se necesita. Esto tiene una ventaja real en proyectos grandes: Vite puede analizar qué componentes se usan realmente y excluir del build final los que no se importan en ninguna parte (esto se llama *tree-shaking*), produciendo un archivo final más pequeño y rápido de cargar.

## 14. Vue Router: múltiples páginas en una SPA

```bash
npm install vue-router
```

```js
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import Catalogo from '../views/Catalogo.vue';
import DetalleProducto from '../views/DetalleProducto.vue';

const routes = [
  { path: '/', name: 'catalogo', component: Catalogo },
  { path: '/producto/:id', name: 'detalle', component: DetalleProducto }
];

export default createRouter({
  history: createWebHistory(),
  routes
});
```

```js
// main.js
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';

createApp(App).use(router).mount('#app');
```

```vue
<!-- App.vue -->
<template>
  <nav>
    <router-link to="/">Catálogo</router-link>
  </nav>
  <router-view></router-view>
</template>
```

**`router-view`** es el "hueco" donde se renderiza el componente correspondiente a la ruta actual — conceptualmente similar a un `<slot>`, pero controlado por la URL en vez de por el componente padre directo. **`router-link`** reemplaza a `<a href="...">`: internamente actualiza la URL y cambia el componente mostrado **sin recargar la página completa**, que es justamente lo que distingue a una SPA de un sitio tradicional multi-página.

### Parámetros de ruta y navegación programática

```vue
<!-- DetalleProducto.vue -->
<script>
export default {
  computed: {
    idProducto() {
      return this.$route.params.id; // lee el ":id" de la URL, ej: /producto/3 → "3"
    }
  },
  methods: {
    volver() {
      this.$router.push('/'); // navega programáticamente, ej: después de confirmar una compra
    }
  }
};
</script>
```

`this.$route` da acceso a información de la ruta actual (parámetros, query strings); `this.$router` permite navegar desde código (no solo desde clics en `router-link`), útil por ejemplo para redirigir automáticamente a la pantalla de confirmación después de un checkout exitoso.

## 15. Pinia: estado global de la aplicación

Cuando el carrito de compras necesita ser visible y modificable tanto desde el catálogo como desde un ícono en el header (componentes que no son padre-hijo directo), pasar esa información manualmente a través de varios niveles de `props`/`$emit` se vuelve incómodo — esto se conoce como **"prop drilling"**. Pinia centraliza ese estado en un solo lugar accesible desde cualquier componente.

```bash
npm install pinia
```

```js
// main.js
import { createPinia } from 'pinia';
createApp(App).use(createPinia()).use(router).mount('#app');
```

```js
// src/stores/carrito.js
import { defineStore } from 'pinia';

export const useCarritoStore = defineStore('carrito', {
  state: () => ({
    items: []
  }),
  getters: {
    // equivalente a una "computed" del Bloque 03, pero a nivel global
    total(state) {
      return state.items.reduce((acc, item) => acc + item.precio * item.cantidad, 0);
    },
    totalItems(state) {
      return state.items.reduce((acc, item) => acc + item.cantidad, 0);
    }
  },
  actions: {
    // equivalente a "methods", pero que modifican el estado global
    agregar(producto) {
      const existente = this.items.find(i => i.id === producto.id);
      if (existente) {
        existente.cantidad++;
      } else {
        this.items.push({ ...producto, cantidad: 1 });
      }
    },
    eliminar(id) {
      this.items = this.items.filter(i => i.id !== id);
    },
    vaciar() {
      this.items = [];
    }
  }
});
```

**Uso desde cualquier componente**, sin importar qué tan lejos esté en el árbol de componentes:
```vue
<script>
import { useCarritoStore } from '../stores/carrito';

export default {
  setup() {
    const carrito = useCarritoStore();
    return { carrito };
  }
};
</script>

<template>
  <p>Carrito ({{ carrito.totalItems }}) - ${{ carrito.total }}</p>
</template>
```

**`state`** define los datos reactivos (equivalente a `data()`), **`getters`** son valores derivados cacheados (equivalente a `computed`), y **`actions`** son las funciones que modifican el estado (equivalente a `methods`, pero accesibles globalmente). La regla de oro: **ningún componente debe modificar `carrito.items` directamente** (`carrito.items.push(...)` desde afuera del store); siempre debe hacerse a través de una `action` (`carrito.agregar(...)`), para mantener toda la lógica de negocio centralizada en un solo lugar y evitar que el estado se modifique de formas inconsistentes desde distintas partes de la app.

## 16. Manejo robusto de errores en una aplicación Vue real

En el Bloque 02 viste cómo manejar errores con `try/catch` en JavaScript puro. En una aplicación Vue de producción, esto se traduce en patrones específicos:

```vue
<script>
export default {
  data() {
    return { productos: [], cargando: false, error: null };
  },
  async mounted() {
    await this.cargarProductos();
  },
  methods: {
    async cargarProductos() {
      this.cargando = true;
      this.error = null;
      try {
        const respuesta = await fetch('https://api.ejemplo.com/productos');
        if (!respuesta.ok) throw new Error('No se pudieron cargar los productos');
        this.productos = await respuesta.json();
      } catch (e) {
        this.error = e.message;
      } finally {
        this.cargando = false;
      }
    }
  }
};
</script>

<template>
  <p v-if="cargando">Cargando productos...</p>
  <p v-else-if="error">⚠️ {{ error }} <button @click="cargarProductos">Reintentar</button></p>
  <div v-else-if="productos.length === 0">No hay productos disponibles.</div>
  <div v-else><!-- mostrar productos normalmente --></div>
</template>
```

Este patrón (cargando / error con botón de reintentar / vacío / éxito) es el **mínimo esperado** en cualquier aplicación que consuma datos externos en un entorno profesional — una app que simplemente "se queda en blanco" si la API falla se considera de baja calidad en una revisión de código o entrevista técnica.

### Captura global de errores (avanzado)
```js
// main.js
app.config.errorHandler = (err, instance, info) => {
  console.error('Error capturado globalmente:', err, info);
  // aquí en un proyecto real se podría enviar el error a un servicio de monitoreo
};
```
Esto captura errores no manejados que ocurren en cualquier componente de la aplicación, evitando que un error en una parte aislada de la interfaz "rompa" toda la aplicación sin dejar rastro.

## 17. Construcción del proyecto insignia con arquitectura de producción

Con todo lo anterior, el e-commerce del Bloque 03 (originalmente un solo archivo HTML) se reorganiza así para la Semana 6:

```
src/
  components/
    ProductoCard.vue
    CarritoItem.vue
  views/
    Catalogo.vue
    Checkout.vue
    Confirmacion.vue
  stores/
    carrito.js
  router/
    index.js
  App.vue
  main.js
```

**Diferencias clave respecto a la versión de la Semana 5:**
- El estado del carrito vive en `stores/carrito.js` (Pinia), no en el componente raíz — accesible desde `Catalogo.vue` y desde un ícono de carrito en el header sin pasar props manualmente.
- El flujo carrito → checkout → confirmación, que antes se controlaba con una variable `vista` y `v-if`, ahora son **rutas reales** (`/`, `/checkout`, `/confirmacion`) navegables con `vue-router`, cada una con su propia URL.
- Cada componente vive en su propio archivo `.vue`, con estilos `scoped` que no chocan entre sí.
- La carga de datos (si se migra de productos fijos a una API real) sigue el patrón completo de manejo de errores de la sección 16.

Este es exactamente el nivel de organización que se espera revisar en el código fuente de un candidato júnior — y es la diferencia entre un proyecto que "funciona" y uno que demuestra buenas prácticas de arquitectura.

---

## Ejercicios de la Semana 6 (nivel producción)

### Ejercicio 6.3 — Migración a Vite
Toma el e-commerce construido con CDN (Semana 5) y migra su estructura a un proyecto Vite, separando al menos `ProductoCard` y `CarritoItem` en sus propios archivos `.vue`.

### Ejercicio 6.4 — Pinia
Mueve toda la lógica del carrito (`agregar`, `eliminar`, `total`, `totalItems`) a un store de Pinia, y elimina esa lógica del componente raíz. Verifica que el carrito siga funcionando igual desde la perspectiva del usuario.

### Ejercicio 6.5 — Rutas reales
Convierte las "vistas" controladas por `v-if` (carrito/checkout/confirmación) en rutas reales con `vue-router`. Agrega también una ruta `/producto/:id` con una vista de detalle de producto individual, enlazada desde cada tarjeta del catálogo.

### Ejercicio 6.6 — Manejo de errores
Simula que el endpoint de "confirmar compra" falla aleatoriamente (por ejemplo, usando `Math.random()`), y maneja ese error mostrando un mensaje apropiado con opción de reintentar, sin que el carrito se vacíe si la compra falló.

---

## Imágenes de referencia para el proyecto de este bloque

**Proyecto #5 — E-commerce completo**: catálogo de productos en cuadrícula con imagen, nombre y precio; panel lateral de carrito con control de cantidad por producto; total claramente visible; flujo de checkout con formulario de datos de envío y confirmación de compra.

(Ver las imágenes de referencia de "shopping cart UI design" mostradas en la conversación para ejemplos visuales reales de carritos de compra y catálogos.)

